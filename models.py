# backend/app/models.py
import uuid
from sqlalchemy import Column, Integer, String, Text, Numeric, Date, DateTime, Enum, ForeignKey, Time, Computed
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from database import Base 
from datetime import date
from sqlalchemy.orm import relationship

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    role = Column(String, default="user")
    deleted_at = Column(DateTime, nullable=True)

class Project(Base):
    __tablename__ = "projects"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    model = Column(Enum("WATERFALL", "AGILE", "HYBRID", name="project_model"), nullable=False, default="WATERFALL")
    allocation_mode = Column(Enum("SQUAD", "DIRECT", name="allocation_mode"), nullable=False, default="SQUAD")
    
    client_id = Column(UUID(as_uuid=True), nullable=True)
    calendar_id = Column(UUID(as_uuid=True), nullable=True)
    manager_user_id = Column(UUID(as_uuid=True), nullable=True)
    
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    status = Column(String, nullable=False, default="DRAFT")
    
    start_date = Column(Date, nullable=False, default=date.today)
    end_date = Column(Date, nullable=True)
    
    currency = Column(String(3), default="BRL")
    estimated_cost = Column(Numeric, nullable=True)
    estimated_revenue = Column(Numeric, nullable=True)
    
    hubspot_deal_id = Column(String, nullable=True)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    deleted_at = Column(DateTime(timezone=True), nullable=True)

    tasks = relationship("Task", backref="project")

class Task(Base):
    __tablename__ = "tasks"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    project_id = Column(UUID(as_uuid=True), ForeignKey("projects.id"), nullable=False)
    
    sprint_id = Column(UUID(as_uuid=True), nullable=True)
    milestone_id = Column(UUID(as_uuid=True), nullable=True)
    parent_task_id = Column(UUID(as_uuid=True), nullable=True)
    assigned_user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    
    status = Column(String, default="TODO") 
    priority = Column(String, default="MEDIUM")
    
    billable = Column(
        Enum("BILLABLE", "NON_BILLABLE", name="billable_type"), 
        default="BILLABLE"
    )
    
    story_points = Column(Integer, nullable=True)
    estimated_effort_hours = Column(Integer, nullable=False)
    start_date = Column(Date, nullable=True)
    end_date = Column(Date, nullable=True)
    due_date = Column(Date, nullable=True)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    deleted_at = Column(DateTime(timezone=True), nullable=True)

    timelogs = relationship("TimeLog", backref="task")

class TimeLog(Base):
    __tablename__ = "time_logs"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    task_id = Column(UUID(as_uuid=True), ForeignKey("tasks.id"), nullable=False)
    user_id = Column(UUID(as_uuid=True), nullable=False)
    logged_date = Column(Date, nullable=False)
    start_time = Column(Time, nullable=True)
    end_time = Column(Time, nullable=True)
    
    # CORREÇÃO: O banco calcula isso, então usamos 'Computed' para que o SQLAlchemy não tente inserir
    hours_spent = Column(Numeric(10, 2), Computed("end_time - start_time", persisted=True))
    
    billable = Column(Enum("BILLABLE", "NON_BILLABLE", name="billable_type", create_type=False), default="BILLABLE")
    
    # CORREÇÃO: Atualizado para os valores que o seu banco espera
    entry_type = Column(Enum("REGULAR", "ADDITIONAL", "OVERTIME", name="timelog_entry_type", create_type=False), default="REGULAR")
    
    approval_status = Column(Enum("PENDING", "APPROVED", "REJECTED", name="approval_status_enum", create_type=False), default="PENDING")
        
    approved_by = Column(UUID(as_uuid=True), nullable=True)
    approved_at = Column(DateTime(timezone=True), nullable=True)
    rejection_reason = Column(Text, nullable=True)
    revision_note = Column(Text, nullable=True)
    payment_release_id = Column(UUID(as_uuid=True), nullable=True)
    description = Column(Text, nullable=True)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    deleted_at = Column(DateTime(timezone=True), nullable=True)