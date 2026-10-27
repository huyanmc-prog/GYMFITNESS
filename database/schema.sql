-- ==============================================================================
-- GYM TRACKER CORE DATABASE SCHEMA (PostgreSQL / SQLite Compatible)
-- ==============================================================================

-- 1. DANH MỤC NHÓM CƠ
CREATE TABLE IF NOT EXISTS muscles (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    body_part VARCHAR(50) NOT NULL
);

-- 2. DANH MỤC BÀI TẬP (Hơn 800+ bài tập)
CREATE TABLE IF NOT EXISTS exercises (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    equipment VARCHAR(50) NOT NULL,
    mechanic VARCHAR(50),
    force_type VARCHAR(50),
    primary_muscle_id VARCHAR(50) REFERENCES muscles(id),
    secondary_muscles TEXT,
    instructions TEXT,
    image_paths TEXT,
    is_custom BOOLEAN DEFAULT FALSE,
    user_id VARCHAR(100) DEFAULT NULL
);

-- 3. MẪU LỊCH TẬP (ROUTINES / TEMPLATES)
CREATE TABLE IF NOT EXISTS routines (
    id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(100) NOT NULL,
    title VARCHAR(150) NOT NULL,
    split_folder VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. BÀI TẬP TRONG MẪU LỊCH TẬP
CREATE TABLE IF NOT EXISTS routine_exercises (
    id VARCHAR(50) PRIMARY KEY,
    routine_id VARCHAR(50) NOT NULL REFERENCES routines(id) ON DELETE CASCADE,
    exercise_id VARCHAR(100) NOT NULL REFERENCES exercises(id),
    order_index INT NOT NULL,
    target_sets INT DEFAULT 3,
    target_reps_min INT DEFAULT 8,
    target_reps_max INT DEFAULT 12,
    target_rpe NUMERIC(3,1),
    rest_seconds INT DEFAULT 90,
    notes TEXT
);

-- 5. BUỔI TẬP THỰC TẾ (WORKOUT SESSIONS)
CREATE TABLE IF NOT EXISTS workouts (
    id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(100) NOT NULL,
    routine_id VARCHAR(50) REFERENCES routines(id) ON DELETE SET NULL,
    title VARCHAR(150) NOT NULL,
    started_at TIMESTAMP WITH TIME ZONE NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE,
    duration_seconds INT,
    total_volume_kg NUMERIC(10,2) DEFAULT 0,
    total_completed_sets INT DEFAULT 0,
    rating_score INT CHECK (rating_score BETWEEN 1 AND 5),
    notes TEXT
);

-- 6. CHI TIẾT TỪNG SET TRONG BUỔI TẬP
CREATE TABLE IF NOT EXISTS workout_sets (
    id VARCHAR(50) PRIMARY KEY,
    workout_id VARCHAR(50) NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
    exercise_id VARCHAR(100) NOT NULL REFERENCES exercises(id),
    set_order INT NOT NULL,
    set_type VARCHAR(20) DEFAULT 'normal',
    weight_kg NUMERIC(6,2) NOT NULL,
    reps INT NOT NULL,
    rpe NUMERIC(3,1),
    rir INT,
    is_completed BOOLEAN DEFAULT TRUE,
    is_personal_record BOOLEAN DEFAULT FALSE,
    estimated_1rm_kg NUMERIC(6,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7. KỶ LỤC CÁ NHÂN (PERSONAL RECORDS)
CREATE TABLE IF NOT EXISTS personal_records (
    id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(100) NOT NULL,
    exercise_id VARCHAR(100) NOT NULL REFERENCES exercises(id),
    record_type VARCHAR(50) NOT NULL,
    value NUMERIC(10,2) NOT NULL,
    workout_set_id VARCHAR(50) REFERENCES workout_sets(id),
    achieved_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 8. THEO DÕI CHỈ SỐ CƠ THỂ
CREATE TABLE IF NOT EXISTS body_metrics (
    id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(100) NOT NULL,
    measured_date DATE NOT NULL,
    weight_kg NUMERIC(5,2),
    body_fat_percentage NUMERIC(4,2),
    notes TEXT
);

-- INDEXES TỐI ƯU HÓA TRUY VẤN
CREATE INDEX IF NOT EXISTS idx_workout_sets_exercise ON workout_sets(exercise_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_workouts_user_started ON workouts(user_id, started_at DESC);
CREATE INDEX IF NOT EXISTS idx_routine_exercises_routine ON routine_exercises(routine_id, order_index ASC);
