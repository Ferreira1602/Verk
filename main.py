# backend/app/main.py
import uuid
from fastapi import FastAPI, HTTPException, Depends
from sqlalchemy.orm import Session
from database import get_db, engine
from models import Project as ProjectModel, Task as TaskModel, TimeLog as TimeLogModel
from schemas import ProjetoCreate, TaskCreate, TimeLogCreate
from sqlalchemy import inspect
from sqlalchemy import func
from fastapi import Query
from datetime import date
from sqlalchemy import and_
from datetime import datetime
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Norn Platform API", version="1.0.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Em produção, substitua pelo domínio do front-end
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Verificação de conexão e tabelas no startup
@app.on_event("startup")
def check_tables():
    try:
        inspector = inspect(engine)
        tables = inspector.get_table_names()
        print("Tabelas encontradas no banco:", tables)
        if "time_logs" not in tables:
            print("AVISO: Tabela 'time_logs' não encontrada no banco!")
    except Exception as e:
        print(f"Erro ao conectar ao banco ou inspecionar tabelas: {e}")

# --- PROJETOS ---
@app.post("/projects", status_code=201)
def create_project(projeto: ProjetoCreate, db: Session = Depends(get_db)):
    dados = projeto.model_dump()
    dados["model"] = dados.get("model", "WATERFALL").upper()
    dados["allocation_mode"] = dados.get("allocation_mode", "SQUAD").upper()
    dados["status"] = dados.get("status", "DRAFT").upper()
    
    if "nome" in dados: dados["title"] = dados.pop("nome")
    if "descricao" in dados: dados["description"] = dados.pop("descricao")
    if "id" not in dados or dados["id"] is None: dados["id"] = uuid.uuid4()
    
    novo_projeto = ProjectModel(**dados)
    db.add(novo_projeto)
    db.commit()
    db.refresh(novo_projeto)
    return novo_projeto

@app.get("/projects", status_code=200)
def list_projects(db: Session = Depends(get_db)):
    return db.query(ProjectModel).all()

# --- TAREFAS ---
@app.post("/tasks", status_code=201)
def create_task(task: TaskCreate, db: Session = Depends(get_db)):
    dados = task.model_dump()
    if "id" not in dados or dados["id"] is None: dados["id"] = uuid.uuid4()
    
    novo_task = TaskModel(**dados)
    db.add(novo_task)
    db.commit()
    db.refresh(novo_task)
    return novo_task

@app.get("/projects/{project_id}/tasks", status_code=200)
def list_tasks_by_project(project_id: uuid.UUID, db: Session = Depends(get_db)):
    return db.query(TaskModel).filter(TaskModel.project_id == project_id).all()

# --- TIMELOGS ---
@app.post("/timelogs", status_code=201)
def create_timelog(timelog: TimeLogCreate, db: Session = Depends(get_db)):
    task = db.query(TaskModel).filter(TaskModel.id == timelog.task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Tarefa não encontrada")

    dados = timelog.model_dump()
    
    # IMPORTANTE: Remover o campo gerado automaticamente pelo banco
    if "hours_spent" in dados:
        del dados["hours_spent"]
    
    dados["id"] = uuid.uuid4()
    dados["approval_status"] = "PENDING" 
    
    valor_entry = dados.get("entry_type", "").upper()
    if valor_entry not in ["REGULAR", "ADDITIONAL", "OVERTIME"]:
        raise HTTPException(status_code=400, detail="Tipo de entrada inválido. Use REGULAR, ADDITIONAL ou OVERTIME.")
    
    dados["entry_type"] = valor_entry
    
    novo_log = TimeLogModel(**dados)
    db.add(novo_log)
    db.commit()
    db.refresh(novo_log)
    return novo_log

@app.patch("/timelogs/{timelog_id}/status", status_code=200)
def update_timelog_status(
    timelog_id: uuid.UUID, 
    new_status: str, 
    approved_by_id: uuid.UUID,  # Adicione este parâmetro
    db: Session = Depends(get_db)
):
    log = db.query(TimeLogModel).filter(TimeLogModel.id == timelog_id).first()
    if not log:
        raise HTTPException(status_code=404, detail="Registro de horas não encontrado")
    
    if log.approval_status == "APPROVED":
        raise HTTPException(status_code=400, detail="Não é possível alterar um registro já aprovado")
        
    # Atualiza o status
    log.approval_status = new_status.upper()
    
    # Adiciona os campos de auditoria
    if log.approval_status == "APPROVED":
        log.approved_by = approved_by_id
        log.approved_at = datetime.utcnow()
        
    db.commit()
    db.refresh(log)
    return log

@app.get("/projects/{project_id}/dashboard")
def get_project_dashboard(project_id: uuid.UUID, db: Session = Depends(get_db)):
    # Consulta: Soma de horas realizadas por tarefa vinculada ao projeto
    stats = (
        db.query(
            TaskModel.id,
            TaskModel.title,
            TaskModel.estimated_effort_hours,
            func.sum(TimeLogModel.hours_spent).label("actual_hours")
        )
        .outerjoin(TimeLogModel, TaskModel.id == TimeLogModel.task_id)
        .filter(TaskModel.project_id == project_id)
        .group_by(TaskModel.id)
        .all()
    )

    # Formatar resposta
    summary = []
    for s in stats:
        estimated = s.estimated_effort_hours or 0
        actual = float(s.actual_hours or 0)
        summary.append({
            "task_id": s.id,
            "title": s.title,
            "estimated_hours": estimated,
            "actual_hours": actual,
            "remaining_hours": max(0, estimated - actual),
            "percentage_completed": round((actual / estimated * 100) if estimated > 0 else 0, 2)
        })
    
    return summary

@app.get("/reports/approval-status")
def get_approval_report(
    start_date: date = Query(None),
    end_date: date = Query(None),
    user_id: uuid.UUID = Query(None),
    project_id: uuid.UUID = Query(None), # Necessário join com Task
    db: Session = Depends(get_db)
):
    # Base da query
    query = db.query(
        TimeLogModel.approval_status,
        func.sum(TimeLogModel.hours_spent).label("total_hours"),
        func.count(TimeLogModel.id).label("log_count")
    )
    
    # Se filtrar por projeto, precisamos da relação com Task
    if project_id:
        query = query.join(TaskModel, TimeLogModel.task_id == TaskModel.id).filter(TaskModel.project_id == project_id)

    # Aplicação dinâmica de outros filtros
    filters = []
    if start_date:
        filters.append(TimeLogModel.logged_date >= start_date)
    if end_date:
        filters.append(TimeLogModel.logged_date <= end_date)
    if user_id:
        filters.append(TimeLogModel.user_id == user_id)
    
    if filters:
        query = query.filter(and_(*filters))

    report = query.group_by(TimeLogModel.approval_status).all()

    return [
        {
            "status": r.approval_status,
            "total_hours": float(r.total_hours or 0),
            "log_count": r.log_count
        }
        for r in report
    ]