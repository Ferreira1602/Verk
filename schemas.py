# backend/app/schemas.py
from pydantic import BaseModel, Field
from typing import Optional
from datetime import date, datetime, time
from uuid import UUID
from decimal import Decimal

# Lista de papéis válidos atualizada com "HEAD"
VALID_USER_ROLES = ["user", "manager", "admin", "ADMINISTRATOR", "HEAD"]

# --- USUÁRIOS ---
class UserCreate(BaseModel):
    name: str
    email: str
    password: str
    role: str = "user"
    weekly_capacity_hours: Optional[Decimal] = Decimal("40.0")

class UserUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None
    role: Optional[str] = None
    weekly_capacity_hours: Optional[Decimal] = None
    is_active: Optional[bool] = None

class UserOut(BaseModel):
    id: UUID
    name: str
    email: str
    role: str
    weekly_capacity_hours: Optional[Decimal] = None
    is_active: bool
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True

# --- CLIENTES ---
class ClientCreate(BaseModel):
    name: str
    region: Optional[str] = None
    default_currency: Optional[str] = "BRL"

class ClientUpdate(BaseModel):
    name: Optional[str] = None
    region: Optional[str] = None
    default_currency: Optional[str] = None

class ClientOut(BaseModel):
    id: UUID
    name: str
    region: Optional[str] = None
    default_currency: Optional[str] = "BRL"
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True

# --- PROJETOS ---
class ProjetoBase(BaseModel):
    title: str = Field(..., alias="nome") 
    description: Optional[str] = None
    status: str = "DRAFT" 
    model: str = "WATERFALL"
    allocation_mode: str = "SQUAD"
    client_id: Optional[UUID] = None
    calendar_id: Optional[UUID] = None
    manager_user_id: Optional[UUID] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    currency: str = "BRL"
    estimated_cost: Decimal = Decimal('0.0')
    estimated_revenue: Decimal = Decimal('0.0')
    hubspot_deal_id: Optional[str] = None

class ProjetoCreate(ProjetoBase):
    pass

class ProjetoUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    status: Optional[str] = None
    model: Optional[str] = None
    allocation_mode: Optional[str] = None
    client_id: Optional[UUID] = None
    calendar_id: Optional[UUID] = None
    manager_user_id: Optional[UUID] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    currency: Optional[str] = None
    estimated_cost: Optional[Decimal] = None
    estimated_revenue: Optional[Decimal] = None
    hubspot_deal_id: Optional[str] = None

    class Config:
        from_attributes = True
        populate_by_name = True

class Projeto(ProjetoBase):
    id: UUID
    
    class Config:
        from_attributes = True
        populate_by_name = True

# --- EQUIPE DO PROJETO ---
class ProjectMemberCreate(BaseModel):
    user_id: UUID

class ProjectMemberOut(BaseModel):
    id: UUID
    project_id: UUID
    user_id: UUID
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True

# --- MARCOS (MILESTONES) ---
class MilestoneCreate(BaseModel):
    title: str
    description: Optional[str] = None
    target_date: date
    status: str = "PENDING"

class MilestoneUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    target_date: Optional[date] = None
    status: Optional[str] = None

    class Config:
        from_attributes = True

class MilestoneOut(BaseModel):
    id: UUID
    project_id: UUID
    title: str
    description: Optional[str] = None
    target_date: date
    status: str
    approved_by: Optional[UUID] = None
    approved_at: Optional[datetime] = None
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True

# --- TAREFAS ---
class TaskBase(BaseModel):
    title: str
    description: Optional[str] = None
    status: str = "TODO"
    project_id: UUID
    assigned_user_id: Optional[UUID] = None
    due_date: Optional[date] = None
    priority: str = "MEDIUM"
    billable: str = "BILLABLE"
    estimated_effort_hours: int
    manual_progress: Optional[int] = None
    sprint_id: Optional[UUID] = None
    milestone_id: Optional[UUID] = None
    parent_task_id: Optional[UUID] = None
    story_points: Optional[int] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None

class TaskCreate(TaskBase):
    pass

class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    status: Optional[str] = None
    priority: Optional[str] = None
    estimated_effort_hours: Optional[int] = None
    manual_progress: Optional[int] = None
    due_date: Optional[date] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    assigned_user_id: Optional[UUID] = None

    class Config:
        from_attributes = True

class Task(TaskBase):
    id: UUID
    created_at: datetime 

    class Config:
        from_attributes = True

# --- COMENTÁRIOS DE TAREFA ---
class TaskCommentCreate(BaseModel):
    comment: str

class TaskCommentOut(BaseModel):
    id: UUID
    task_id: UUID
    author_user_id: UUID
    comment: str
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True

# --- DEPENDÊNCIAS DE TAREFA ---
class TaskDependencyCreate(BaseModel):
    predecessor_task_id: UUID

class TaskDependencyOut(BaseModel):
    id: UUID
    successor_task_id: UUID
    predecessor_task_id: UUID
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True

# --- TIMELOGS ---
class TimeLogBase(BaseModel):
    task_id: UUID
    user_id: UUID
    logged_date: date
    start_time: Optional[time] = None
    end_time: Optional[time] = None
    hours_spent: Decimal = Field(..., gt=0)
    billable: str = "BILLABLE"
    entry_type: str = "WORK"
    description: Optional[str] = None

class TimeLogCreate(BaseModel):
    task_id: UUID
    user_id: UUID
    logged_date: date
    start_time: time
    end_time: time
    billable: str = "BILLABLE"
    entry_type: str = "REGULAR"
    description: Optional[str] = None
    rejection_reason: Optional[str] = None
    revision_note: Optional[str] = None
    payment_release_id: Optional[UUID] = None

    class Config:
        from_attributes = True

class TimeLogUpdate(BaseModel):
    logged_date: Optional[date] = None
    start_time: Optional[time] = None
    end_time: Optional[time] = None
    billable: Optional[str] = None
    entry_type: Optional[str] = None
    description: Optional[str] = None

    class Config:
        from_attributes = True