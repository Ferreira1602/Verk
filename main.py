import logging
import uuid
import io
import pandas as pd
from typing import List
from fastapi import FastAPI, HTTPException, Depends, status, Query, Request
from fastapi.security import OAuth2PasswordRequestForm
from fastapi.responses import JSONResponse, StreamingResponse
from sqlalchemy.orm import Session
from sqlalchemy import inspect, func, and_
from sqlalchemy.exc import SQLAlchemyError
from datetime import datetime, date
from decimal import Decimal
from fastapi.middleware.cors import CORSMiddleware
from passlib.context import CryptContext
import bcrypt

# Importações do projeto
from database import get_db, engine
from models import (
    Project as ProjectModel,
    Task as TaskModel,
    TimeLog as TimeLogModel,
    User as UserModel,
    ProjectMember as ProjectMemberModel,
    Milestone as MilestoneModel,
    TaskComment as TaskCommentModel,
    TaskDependency as TaskDependencyModel,
    Client as ClientModel,
)
from schemas import (
    ProjetoCreate, ProjetoUpdate, TaskCreate, TaskUpdate, TimeLogCreate, TimeLogUpdate, UserOut, UserCreate, UserUpdate,
    ProjectMemberCreate, ProjectMemberOut,
    MilestoneCreate, MilestoneUpdate, MilestoneOut,
    TaskCommentCreate, TaskCommentOut,
    TaskDependencyCreate, TaskDependencyOut,
    ClientCreate, ClientUpdate, ClientOut,
)
from auth import get_current_user, create_access_token, require_manager, require_admin

# Contexto de Senha com bcrypt
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto", bcrypt__ident="2b")

app = FastAPI(
    title="Norn Platform API",
    version="1.0.0",
    description=(
        "API do Verk (gestão de projetos, tarefas e apontamento de horas). "
        "Autentique via POST /login (form-urlencoded: username=e-mail, password=senha) "
        "e use o token retornado como Bearer nas demais rotas."
    ),
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

logger = logging.getLogger("norn.api")

@app.exception_handler(SQLAlchemyError)
async def sqlalchemy_error_handler(request: Request, exc: SQLAlchemyError):
    logger.error("%s em %s %s: %s", type(exc).__name__, request.method, request.url.path, getattr(exc, "orig", exc))
    return JSONResponse(
        status_code=422,
        content={"detail": "Violação de integridade dos dados — verifique campos obrigatórios, tipos e referências (IDs inexistentes)."},
    )

# --- AUTHENTICATION ---

@app.post("/login", tags=["Autenticação"], summary="Login (form-urlencoded)")
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(UserModel).filter(UserModel.email == form_data.username).first()
    
    if not user:
        raise HTTPException(status_code=400, detail="Credenciais inválidas")

    password_bytes = form_data.password.encode('utf-8')[:72]
    stored_hash_bytes = user.password_hash.encode('utf-8')

    if not bcrypt.checkpw(password_bytes, stored_hash_bytes):
        raise HTTPException(status_code=400, detail="Credenciais inválidas")
    
    access_token = create_access_token(user_id=str(user.id))
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/me", tags=["Autenticação"], summary="Usuário logado (a partir do token)")
def read_users_me(current_user: UserModel = Depends(get_current_user)):
    return {
        "user_id": current_user.id,
        "name": current_user.name,
        "email": current_user.email,
        "role": current_user.role,
    }

# --- USUÁRIOS (Restrito a Admin / Head) ---

@app.get("/users", status_code=200, response_model=List[UserOut], tags=["Usuários"], summary="Listar usuários ativos")
def list_users(db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    return db.query(UserModel).filter(UserModel.deleted_at.is_(None)).all()

@app.post(
    "/users",
    status_code=201,
    response_model=UserOut,
    tags=["Usuários"],
    summary="Criar usuário (admin/head)",
)
def create_user(
    user: UserCreate,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(require_admin),
):
    existing = db.query(UserModel).filter(UserModel.email == user.email).first()
    if existing:
        raise HTTPException(status_code=409, detail="Já existe um usuário com este e-mail")

    password_bytes = user.password.encode("utf-8")[:72]
    password_hash = bcrypt.hashpw(password_bytes, bcrypt.gensalt()).decode("utf-8")

    novo_usuario = UserModel(
        id=uuid.uuid4(),
        name=user.name,
        email=user.email,
        password_hash=password_hash,
        role=user.role,
        weekly_capacity_hours=user.weekly_capacity_hours if user.weekly_capacity_hours is not None else Decimal("40.0"),
        auth_provider="LOCAL",
    )
    db.add(novo_usuario)
    db.commit()
    db.refresh(novo_usuario)
    return novo_usuario

@app.patch(
    "/users/{user_id}",
    status_code=200,
    response_model=UserOut,
    tags=["Usuários"],
    summary="Editar usuário (admin/head)",
)
def update_user(
    user_id: uuid.UUID,
    payload: UserUpdate,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(require_admin),
):
    usuario = db.query(UserModel).filter(UserModel.id == user_id, UserModel.deleted_at.is_(None)).first()
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuário não encontrado")

    updates = payload.model_dump(exclude_unset=True)
    if "email" in updates:
        existing = db.query(UserModel).filter(UserModel.email == updates["email"], UserModel.id != user_id).first()
        if existing:
            raise HTTPException(status_code=409, detail="Já existe um usuário com este e-mail")

    for field, value in updates.items():
        setattr(usuario, field, value)

    db.commit()
    db.refresh(usuario)
    return usuario

@app.delete(
    "/users/{user_id}",
    status_code=204,
    tags=["Usuários"],
    summary="Remover usuário (admin/head - soft delete)",
)
def delete_user(
    user_id: uuid.UUID,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(require_admin),
):
    if user_id == current_user.id:
        raise HTTPException(status_code=422, detail="Você não pode remover sua própria conta")

    usuario = db.query(UserModel).filter(UserModel.id == user_id, UserModel.deleted_at.is_(None)).first()
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuário não encontrado")

    usuario.deleted_at = datetime.utcnow()
    usuario.is_active = False
    db.commit()
    return None

# --- CLIENTES ---

@app.get("/clients", response_model=List[ClientOut], status_code=200, tags=["Clientes"], summary="Listar clientes")
def list_clients(db: Session = Depends(get_db), current_user: UserModel = Depends(require_manager)):
    return db.query(ClientModel).filter(ClientModel.deleted_at.is_(None)).all()

@app.post("/clients", response_model=ClientOut, status_code=201, tags=["Clientes"], summary="Criar cliente")
def create_client(client: ClientCreate, db: Session = Depends(get_db), current_user: UserModel = Depends(require_manager)):
    dados = client.model_dump()
    dados["id"] = uuid.uuid4()
    novo_cliente = ClientModel(**dados)
    db.add(novo_cliente)
    db.commit()
    db.refresh(novo_cliente)
    return novo_cliente

@app.patch("/clients/{client_id}", response_model=ClientOut, status_code=200, tags=["Clientes"], summary="Editar cliente")
def update_client(client_id: uuid.UUID, client: ClientUpdate, db: Session = Depends(get_db), current_user: UserModel = Depends(require_manager)):
    db_client = db.query(ClientModel).filter(ClientModel.id == client_id, ClientModel.deleted_at.is_(None)).first()
    if not db_client:
        raise HTTPException(status_code=404, detail="Cliente não encontrado")
    
    dados = client.model_dump(exclude_unset=True)
    for key, value in dados.items():
        setattr(db_client, key, value)
        
    db.commit()
    db.refresh(db_client)
    return db_client

# --- PROJETOS ---

@app.post("/projects", status_code=201, tags=["Projetos"], summary="Criar projeto")
def create_project(projeto: ProjetoCreate, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    dados = projeto.model_dump()
    dados.update({"id": uuid.uuid4(), "model": dados.get("model", "WATERFALL").upper(), 
                  "allocation_mode": dados.get("allocation_mode", "SQUAD").upper(), 
                  "status": dados.get("status", "DRAFT").upper()})
    
    novo_projeto = ProjectModel(**dados)
    db.add(novo_projeto)
    db.commit()
    db.refresh(novo_projeto)
    return novo_projeto

@app.get("/projects", status_code=200, tags=["Projetos"], summary="Listar projetos")
def list_projects(db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    return db.query(ProjectModel).all()

@app.patch("/projects/{project_id}", status_code=200, tags=["Projetos"], summary="Editar projeto")
def update_project(
    project_id: uuid.UUID,
    projeto_update: ProjetoUpdate,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user),
):
    projeto = db.query(ProjectModel).filter(ProjectModel.id == project_id).first()
    if not projeto:
        raise HTTPException(status_code=404, detail="Projeto não encontrado")

    updates = projeto_update.model_dump(exclude_unset=True)
    for field, value in updates.items():
        setattr(projeto, field, value)

    db.commit()
    db.refresh(projeto)
    return projeto

# --- EQUIPE DO PROJETO ---

@app.get(
    "/projects/{project_id}/members",
    status_code=200,
    response_model=List[UserOut],
    tags=["Equipe do Projeto"],
    summary="Listar membros do projeto",
)
def list_project_members(project_id: uuid.UUID, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    return (
        db.query(UserModel)
        .join(ProjectMemberModel, ProjectMemberModel.user_id == UserModel.id)
        .filter(ProjectMemberModel.project_id == project_id)
        .all()
    )

@app.post(
    "/projects/{project_id}/members",
    status_code=201,
    response_model=ProjectMemberOut,
    tags=["Equipe do Projeto"],
    summary="Adicionar membro ao projeto",
)
def add_project_member(
    project_id: uuid.UUID,
    member: ProjectMemberCreate,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user),
):
    projeto = db.query(ProjectModel).filter(ProjectModel.id == project_id).first()
    if not projeto:
        raise HTTPException(status_code=404, detail="Projeto não encontrado")
    usuario = db.query(UserModel).filter(UserModel.id == member.user_id).first()
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuário não encontrado")

    existing = db.query(ProjectMemberModel).filter(
        ProjectMemberModel.project_id == project_id, ProjectMemberModel.user_id == member.user_id
    ).first()
    if existing:
        raise HTTPException(status_code=409, detail="Usuário já faz parte da equipe deste projeto")

    novo_membro = ProjectMemberModel(project_id=project_id, user_id=member.user_id)
    db.add(novo_membro)
    db.commit()
    db.refresh(novo_membro)
    return novo_membro

@app.delete(
    "/projects/{project_id}/members/{user_id}",
    status_code=204,
    tags=["Equipe do Projeto"],
    summary="Remover membro do projeto",
)
def remove_project_member(
    project_id: uuid.UUID,
    user_id: uuid.UUID,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user),
):
    membro = db.query(ProjectMemberModel).filter(
        ProjectMemberModel.project_id == project_id, ProjectMemberModel.user_id == user_id
    ).first()
    if not membro:
        raise HTTPException(status_code=404, detail="Este usuário não faz parte da equipe deste projeto")
    db.delete(membro)
    db.commit()
    return None

# --- MARCOS (MILESTONES) ---

@app.get(
    "/projects/{project_id}/milestones",
    status_code=200,
    response_model=List[MilestoneOut],
    tags=["Marcos"],
    summary="Listar marcos do projeto",
)
def list_milestones(project_id: uuid.UUID, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    return db.query(MilestoneModel).filter(MilestoneModel.project_id == project_id).order_by(MilestoneModel.target_date).all()

@app.post(
    "/projects/{project_id}/milestones",
    status_code=201,
    response_model=MilestoneOut,
    tags=["Marcos"],
    summary="Criar marco",
)
def create_milestone(
    project_id: uuid.UUID,
    milestone: MilestoneCreate,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user),
):
    projeto = db.query(ProjectModel).filter(ProjectModel.id == project_id).first()
    if not projeto:
        raise HTTPException(status_code=404, detail="Projeto não encontrado")

    novo_marco = MilestoneModel(id=uuid.uuid4(), project_id=project_id, **milestone.model_dump())
    db.add(novo_marco)
    db.commit()
    db.refresh(novo_marco)
    return novo_marco

@app.patch(
    "/milestones/{milestone_id}",
    status_code=200,
    response_model=MilestoneOut,
    tags=["Marcos"],
    summary="Editar marco (status, data, aprovação)",
)
def update_milestone(
    milestone_id: uuid.UUID,
    milestone_update: MilestoneUpdate,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user),
):
    marco = db.query(MilestoneModel).filter(MilestoneModel.id == milestone_id).first()
    if not marco:
        raise HTTPException(status_code=404, detail="Marco não encontrado")

    updates = milestone_update.model_dump(exclude_unset=True)
    for field, value in updates.items():
        setattr(marco, field, value)

    if updates.get("status") == "APPROVED":
        marco.approved_by = current_user.id
        marco.approved_at = datetime.utcnow()

    db.commit()
    db.refresh(marco)
    return marco

# --- TAREFAS ---

@app.post("/tasks", status_code=201, tags=["Tarefas"], summary="Criar tarefa")
def create_task(task: TaskCreate, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    dados = task.model_dump()
    dados["id"] = uuid.uuid4()
    novo_task = TaskModel(**dados)
    db.add(novo_task)
    db.commit()
    db.refresh(novo_task)
    return novo_task

@app.get("/projects/{project_id}/tasks", status_code=200, tags=["Tarefas"], summary="Listar tarefas do projeto")
def list_tasks_by_project(project_id: uuid.UUID, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    return db.query(TaskModel).filter(TaskModel.project_id == project_id).all()

@app.get("/tasks/{task_id}", status_code=200, tags=["Tarefas"], summary="Detalhar tarefa")
def get_task(task_id: uuid.UUID, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    task = db.query(TaskModel).filter(TaskModel.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Tarefa não encontrada")
    return task

@app.patch("/tasks/{task_id}", status_code=200, tags=["Tarefas"], summary="Editar tarefa")
def update_task(
    task_id: uuid.UUID,
    task_update: TaskUpdate,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user),
):
    task = db.query(TaskModel).filter(TaskModel.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Tarefa não encontrada")

    updates = task_update.model_dump(exclude_unset=True)
    for field, value in updates.items():
        setattr(task, field, value)

    db.commit()
    db.refresh(task)
    return task

# --- COMENTÁRIOS DE TAREFA ---

@app.get(
    "/tasks/{task_id}/comments",
    status_code=200,
    response_model=List[TaskCommentOut],
    tags=["Comentários"],
    summary="Listar comentários da tarefa",
)
def list_task_comments(task_id: uuid.UUID, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    return (
        db.query(TaskCommentModel)
        .filter(TaskCommentModel.task_id == task_id, TaskCommentModel.deleted_at.is_(None))
        .order_by(TaskCommentModel.created_at)
        .all()
    )

@app.post(
    "/tasks/{task_id}/comments",
    status_code=201,
    response_model=TaskCommentOut,
    tags=["Comentários"],
    summary="Comentar em uma tarefa",
)
def create_task_comment(
    task_id: uuid.UUID,
    comment: TaskCommentCreate,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user),
):
    task = db.query(TaskModel).filter(TaskModel.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Tarefa não encontrada")

    novo_comentario = TaskCommentModel(
        id=uuid.uuid4(), task_id=task_id, author_user_id=current_user.id, **comment.model_dump()
    )
    db.add(novo_comentario)
    db.commit()
    db.refresh(novo_comentario)
    return novo_comentario

# --- DEPENDÊNCIAS DE TAREFA ---

@app.get(
    "/tasks/{task_id}/dependencies",
    status_code=200,
    response_model=List[TaskDependencyOut],
    tags=["Dependências"],
    summary="Listar predecessoras de uma tarefa",
)
def list_task_dependencies(task_id: uuid.UUID, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    return db.query(TaskDependencyModel).filter(TaskDependencyModel.successor_task_id == task_id).all()

@app.post(
    "/tasks/{task_id}/dependencies",
    status_code=201,
    response_model=TaskDependencyOut,
    tags=["Dependências"],
    summary="Criar dependência entre tarefas",
)
def create_task_dependency(
    task_id: uuid.UUID,
    dependency: TaskDependencyCreate,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user),
):
    if dependency.predecessor_task_id == task_id:
        raise HTTPException(status_code=422, detail="Uma tarefa não pode depender de si mesma")

    task = db.query(TaskModel).filter(TaskModel.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Tarefa não encontrada")
    predecessora = db.query(TaskModel).filter(TaskModel.id == dependency.predecessor_task_id).first()
    if not predecessora:
        raise HTTPException(status_code=404, detail="Tarefa predecessora não encontrada")

    nova_dependencia = TaskDependencyModel(
        id=uuid.uuid4(), successor_task_id=task_id, **dependency.model_dump()
    )
    db.add(nova_dependencia)
    db.commit()
    db.refresh(nova_dependencia)
    return nova_dependencia

@app.delete(
    "/tasks/{task_id}/dependencies/{dependency_id}",
    status_code=204,
    tags=["Dependências"],
    summary="Remover dependência",
)
def delete_task_dependency(
    task_id: uuid.UUID,
    dependency_id: uuid.UUID,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user),
):
    dependencia = db.query(TaskDependencyModel).filter(
        TaskDependencyModel.id == dependency_id, TaskDependencyModel.successor_task_id == task_id
    ).first()
    if not dependencia:
        raise HTTPException(status_code=404, detail="Dependência não encontrada")
    db.delete(dependencia)
    db.commit()
    return None

# --- TIMELOGS ---

@app.post(
    "/timelogs",
    status_code=201,
    tags=["Apontamento de Horas"],
    summary="Registrar horas (entra como PENDING)",
)
def create_timelog(timelog: TimeLogCreate, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    task = db.query(TaskModel).filter(TaskModel.id == timelog.task_id).first()
    if not task: raise HTTPException(status_code=404, detail="Tarefa não encontrada")

    dados = timelog.model_dump()
    if "hours_spent" in dados: del dados["hours_spent"]
    
    dados.update({"id": uuid.uuid4(), "approval_status": "PENDING", "user_id": current_user.id})
    
    novo_log = TimeLogModel(**dados)
    db.add(novo_log)
    db.commit()
    db.refresh(novo_log)
    return novo_log

@app.get(
    "/timelogs",
    status_code=200,
    tags=["Apontamento de Horas"],
    summary="Listar apontamentos (filtráveis)",
)
def list_timelogs(
    user_id: uuid.UUID = Query(None),
    project_id: uuid.UUID = Query(None),
    approval_status: str = Query(None),
    start_date: date = Query(None),
    end_date: date = Query(None),
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user),
):
    query = db.query(TimeLogModel)
    if project_id:
        query = query.join(TaskModel, TimeLogModel.task_id == TaskModel.id).filter(TaskModel.project_id == project_id)

    filters = []
    if user_id: filters.append(TimeLogModel.user_id == user_id)
    if approval_status: filters.append(TimeLogModel.approval_status == approval_status.upper())
    if start_date: filters.append(TimeLogModel.logged_date >= start_date)
    if end_date: filters.append(TimeLogModel.logged_date <= end_date)
    if filters: query = query.filter(and_(*filters))

    return query.order_by(TimeLogModel.logged_date.desc()).all()

@app.patch(
    "/timelogs/{timelog_id}",
    status_code=200,
    tags=["Apontamento de Horas"],
    summary="Editar apontamento (só o dono, PENDING/REVISION_REQUESTED)",
)
def update_timelog(
    timelog_id: uuid.UUID,
    payload: TimeLogUpdate,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_user),
):
    log = db.query(TimeLogModel).filter(TimeLogModel.id == timelog_id).first()
    if not log: raise HTTPException(status_code=404, detail="Registro não encontrado")
    if log.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Você só pode editar seus próprios apontamentos")
    if log.approval_status not in ("PENDING", "REVISION_REQUESTED"):
        raise HTTPException(status_code=422, detail="Só é possível editar apontamentos PENDING ou REVISION_REQUESTED")

    updates = payload.model_dump(exclude_unset=True)
    for field, value in updates.items():
        setattr(log, field, value)

    if log.approval_status == "REVISION_REQUESTED":
        log.approval_status = "PENDING"
        log.revision_note = None

    db.commit()
    db.refresh(log)
    return log

VALID_TIMELOG_STATUSES = {"PENDING", "APPROVED", "REJECTED", "REVISION_REQUESTED"}

@app.patch(
    "/timelogs/{timelog_id}/status",
    status_code=200,
    tags=["Apontamento de Horas"],
    summary="Aprovar/rejeitar/pedir revisão (gestor/admin/head)",
)
def update_timelog_status(
    timelog_id: uuid.UUID,
    new_status: str,
    note: str = Query(None, description="Motivo/observação — vai para rejection_reason (REJECTED) ou revision_note (REVISION_REQUESTED)"),
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(require_manager),
):
    new_status_upper = new_status.upper()
    if new_status_upper not in VALID_TIMELOG_STATUSES:
        raise HTTPException(
            status_code=422,
            detail=f"new_status inválido. Use um de: {', '.join(sorted(VALID_TIMELOG_STATUSES))}",
        )

    log = db.query(TimeLogModel).filter(TimeLogModel.id == timelog_id).first()
    if not log: raise HTTPException(status_code=404, detail="Registro não encontrado")

    log.approval_status = new_status_upper
    if log.approval_status == "APPROVED":
        log.approved_by = current_user.id
        log.approved_at = datetime.utcnow()
    elif log.approval_status == "REJECTED" and note:
        log.rejection_reason = note
    elif log.approval_status == "REVISION_REQUESTED" and note:
        log.revision_note = note

    db.commit()
    db.refresh(log)
    return log

# --- EXPORTAÇÃO DIRETA DO BANCO PARA EXCEL ---

@app.get("/api/export/database-dump", tags=["Export"], summary="Exportar dados do banco para Excel")
def export_database_dump(db: Session = Depends(get_db), current_user: UserModel = Depends(require_manager)):
    """
    Exporta um arquivo Excel (.xlsx) consolidado com as principais tabelas da plataforma Norn:
    clients, projects, tasks, time_logs e users em abas separadas.
    """
    try:
        clients = db.query(ClientModel).filter(ClientModel.deleted_at.is_(None)).all()
        projects = db.query(ProjectModel).filter(ProjectModel.deleted_at.is_(None)).all() if hasattr(ProjectModel, "deleted_at") else db.query(ProjectModel).all()
        tasks = db.query(TaskModel).filter(TaskModel.deleted_at.is_(None)).all() if hasattr(TaskModel, "deleted_at") else db.query(TaskModel).all()
        time_logs = db.query(TimeLogModel).filter(TimeLogModel.deleted_at.is_(None)).all() if hasattr(TimeLogModel, "deleted_at") else db.query(TimeLogModel).all()
        users = db.query(UserModel).filter(UserModel.deleted_at.is_(None)).all()

        df_clients = pd.DataFrame([
            {
                "ID": str(c.id),
                "Name": c.name,
                "Region": getattr(c, "region", None),
                "Default Currency": getattr(c, "default_currency", "BRL"),
                "Created At": c.created_at.isoformat() if getattr(c, "created_at", None) else None
            } for c in clients
        ])

        df_projects = pd.DataFrame([
            {
                "ID": str(p.id),
                "Client ID": str(p.client_id) if getattr(p, "client_id", None) else None,
                "Title": p.title,
                "Model": p.model.value if hasattr(p.model, 'value') else p.model,
                "Allocation Mode": p.allocation_mode.value if hasattr(p.allocation_mode, 'value') else p.allocation_mode,
                "Status": p.status.value if hasattr(p.status, 'value') else p.status,
                "Start Date": p.start_date.isoformat() if getattr(p, "start_date", None) else None,
                "End Date": p.end_date.isoformat() if getattr(p, "end_date", None) else None,
            } for p in projects
        ])

        df_users = pd.DataFrame([
            {
                "ID": str(u.id),
                "Name": u.name,
                "Email": u.email,
                "Role": u.role.value if hasattr(u.role, 'value') else u.role,
                "Weekly Capacity Hours": float(u.weekly_capacity_hours) if u.weekly_capacity_hours is not None else 0.0,
                "Is Active": u.is_active
            } for u in users
        ])

        df_tasks = pd.DataFrame([
            {
                "ID": str(t.id),
                "Project ID": str(t.project_id),
                "Assigned User ID": str(t.assigned_user_id) if t.assigned_user_id else None,
                "Title": t.title,
                "Status": t.status.value if hasattr(t.status, 'value') else t.status,
                "Priority": t.priority.value if hasattr(t.priority, 'value') else t.priority,
                "Estimated Effort Hours": t.estimated_effort_hours,
                "Manual Progress": getattr(t, "manual_progress", None)
            } for t in tasks
        ])

        df_timelogs = pd.DataFrame([
            {
                "ID": str(tl.id),
                "Task ID": str(tl.task_id),
                "User ID": str(tl.user_id),
                "Logged Date": tl.logged_date.isoformat() if tl.logged_date else None,
                "Hours Spent": float(tl.hours_spent) if tl.hours_spent is not None else 0.0,
                "Approval Status": tl.approval_status.value if hasattr(tl.approval_status, 'value') else tl.approval_status,
                "Entry Type": tl.entry_type.value if hasattr(tl.entry_type, 'value') else tl.entry_type
            } for tl in time_logs
        ])

        output = io.BytesIO()
        with pd.ExcelWriter(output, engine="openpyxl") as writer:
            if not df_clients.empty: df_clients.to_excel(writer, index=False, sheet_name="Clients")
            if not df_projects.empty: df_projects.to_excel(writer, index=False, sheet_name="Projects")
            if not df_users.empty: df_users.to_excel(writer, index=False, sheet_name="Users")
            if not df_tasks.empty: df_tasks.to_excel(writer, index=False, sheet_name="Tasks")
            if not df_timelogs.empty: df_timelogs.to_excel(writer, index=False, sheet_name="Time Logs")
        
        output.seek(0)
        filename = f"norn_export_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}.xlsx"
        
        return StreamingResponse(
            output,
            media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            headers={
                "Content-Disposition": f"attachment; filename={filename}"
            }
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao gerar exportação em Excel: {str(e)}")

# --- DASHBOARD & REPORTS ---

@app.get(
    "/projects/{project_id}/dashboard",
    tags=["Relatórios"],
    summary="Progresso por tarefa (horas estimadas × realizadas)",
)
def get_project_dashboard(project_id: uuid.UUID, db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    stats = db.query(TaskModel.id, TaskModel.title, TaskModel.estimated_effort_hours, func.sum(TimeLogModel.hours_spent).label("actual_hours"))\
              .outerjoin(TimeLogModel, TaskModel.id == TimeLogModel.task_id)\
              .filter(TaskModel.project_id == project_id).group_by(TaskModel.id).all()
    
    return [{
        "task_id": s.id, "title": s.title, "estimated_hours": s.estimated_effort_hours or 0,
        "actual_hours": float(s.actual_hours or 0), "remaining_hours": max(0, (s.estimated_effort_hours or 0) - float(s.actual_hours or 0)),
        "percentage_completed": round((float(s.actual_hours or 0) / s.estimated_effort_hours * 100) if (s.estimated_effort_hours or 0) > 0 else 0, 2)
    } for s in stats]

@app.get(
    "/reports/approval-status",
    tags=["Relatórios"],
    summary="Total de horas por status de aprovação",
)
def get_approval_report(start_date: date = Query(None), end_date: date = Query(None), user_id: uuid.UUID = Query(None), project_id: uuid.UUID = Query(None), db: Session = Depends(get_db), current_user: UserModel = Depends(get_current_user)):
    query = db.query(TimeLogModel.approval_status, func.sum(TimeLogModel.hours_spent).label("total_hours"), func.count(TimeLogModel.id).label("log_count"))
    if project_id: query = query.join(TaskModel, TimeLogModel.task_id == TaskModel.id).filter(TaskModel.project_id == project_id)
    filters = []
    if start_date: filters.append(TimeLogModel.logged_date >= start_date)
    if end_date: filters.append(TimeLogModel.logged_date <= end_date)
    if user_id: filters.append(TimeLogModel.user_id == user_id)
    if filters: query = query.filter(and_(*filters))
    return [{"status": r.approval_status, "total_hours": float(r.total_hours or 0), "log_count": r.log_count} for r in query.group_by(TimeLogModel.approval_status).all()]