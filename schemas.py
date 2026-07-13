# backend/app/schemas.py
from pydantic import BaseModel, Field
from typing import Optional
from datetime import date, datetime, time
from uuid import UUID
from decimal import Decimal

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

class Projeto(ProjetoBase):
    id: UUID
    
    class Config:
        from_attributes = True
        populate_by_name = True

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
    sprint_id: Optional[UUID] = None
    milestone_id: Optional[UUID] = None
    parent_task_id: Optional[UUID] = None
    story_points: Optional[int] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None

class TaskCreate(TaskBase):
    pass

class Task(TaskBase):
    id: UUID
    created_at: datetime 

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

class TimeLogCreate(TimeLogBase):
    pass

class TimeLogCreate(BaseModel):
    task_id: UUID
    user_id: UUID
    logged_date: date
    start_time: time
    end_time: time
    billable: str = "BILLABLE"
    entry_type: str = "REGULAR"
    description: Optional[str] = None
    # Adicionando os campos que estavam dando erro de "extra field"
    rejection_reason: Optional[str] = None
    revision_note: Optional[str] = None
    payment_release_id: Optional[UUID] = None

    class Config:
        from_attributes = True