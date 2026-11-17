-- =====================================================================
--  JOBFY - Estrutura do banco de dados (só as tabelas, sem dados)
--  SGBD: MySQL 8.0.16+ (MySQL Workbench - Local instance)
--
--  Rode o script inteiro logado como ROOT.
--  ATENÇÃO: ele APAGA o banco `jobfy` existente e cria tudo do zero,
--  vazio (todas as contas cadastradas pelo app serão perdidas).
--
--  Cria as 13 tabelas do Jobfy e o usuário 'Jobfy', que o app usa para
--  conectar. Nenhuma conta, empresa, vaga ou habilidade é inserida.
-- =====================================================================

SET NAMES utf8mb4;

DROP DATABASE IF EXISTS jobfy;
CREATE DATABASE jobfy
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE jobfy;

-- ---------------------------------------------------------------------
-- 1. ACCOUNTS  (login único para usuários, empresas e instituições)
--    A senha NUNCA é salva em texto: o app grava o hash bcrypt.
-- ---------------------------------------------------------------------
CREATE TABLE accounts (
  account_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  email          VARCHAR(150) NOT NULL,
  password_hash  VARCHAR(255) NOT NULL,
  account_type   ENUM('user', 'company', 'institution') NOT NULL,
  is_active      BOOLEAN      NOT NULL DEFAULT TRUE,   -- FALSE = conta excluída/desativada
  created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_accounts_email UNIQUE (email)
);

-- ---------------------------------------------------------------------
-- 2. PERFIS
-- ---------------------------------------------------------------------
CREATE TABLE users (
  user_id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  account_id       INT UNSIGNED NOT NULL,
  name             VARCHAR(120) NOT NULL,
  cpf              CHAR(11),                            -- só números
  gender           ENUM('male', 'female', 'other'),
  birth_date       DATE,
  phone            VARCHAR(20),
  education_level  ENUM('elementary_incomplete', 'elementary_complete',
                        'high_school_incomplete', 'high_school_complete',
                        'technical', 'bachelor_incomplete', 'bachelor_complete',
                        'postgraduate'),
  CONSTRAINT uq_users_account UNIQUE (account_id),
  CONSTRAINT uq_users_cpf     UNIQUE (cpf),
  CONSTRAINT ck_users_cpf     CHECK (cpf IS NULL OR cpf REGEXP '^[0-9]{11}$'),
  CONSTRAINT fk_users_account FOREIGN KEY (account_id)
    REFERENCES accounts (account_id) ON DELETE CASCADE
);

CREATE TABLE companies (
  company_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  account_id     INT UNSIGNED NOT NULL,
  company_name   VARCHAR(150) NOT NULL,                 -- razão social
  trade_name     VARCHAR(150),                          -- nome fantasia
  cnpj           CHAR(14)     NOT NULL,                 -- só números
  phone          VARCHAR(20),
  business_area  VARCHAR(200),                          -- atividade principal (CNAE)
  zip_code       CHAR(8),                               -- CEP, só números
  address        VARCHAR(200),                          -- rua, número, bairro
  city           VARCHAR(100),
  state          CHAR(2),                               -- UF
  description    TEXT,                                  -- sobre a empresa
  CONSTRAINT uq_companies_account UNIQUE (account_id),
  CONSTRAINT uq_companies_cnpj    UNIQUE (cnpj),
  CONSTRAINT ck_companies_cnpj    CHECK (cnpj REGEXP '^[0-9]{14}$'),
  CONSTRAINT ck_companies_zip     CHECK (zip_code IS NULL OR zip_code REGEXP '^[0-9]{8}$'),
  CONSTRAINT fk_companies_account FOREIGN KEY (account_id)
    REFERENCES accounts (account_id) ON DELETE CASCADE
);

CREATE TABLE institutions (
  institution_id  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  account_id      INT UNSIGNED NOT NULL,
  name            VARCHAR(150) NOT NULL,
  cnpj            CHAR(14)     NOT NULL,
  phone           VARCHAR(20),
  CONSTRAINT uq_institutions_account UNIQUE (account_id),
  CONSTRAINT uq_institutions_cnpj    UNIQUE (cnpj),
  CONSTRAINT ck_institutions_cnpj    CHECK (cnpj REGEXP '^[0-9]{14}$'),
  CONSTRAINT fk_institutions_account FOREIGN KEY (account_id)
    REFERENCES accounts (account_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------
-- 3. HABILIDADES E EXPERIÊNCIAS
-- ---------------------------------------------------------------------
CREATE TABLE skills (
  skill_id  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name      VARCHAR(80) NOT NULL,
  CONSTRAINT uq_skills_name UNIQUE (name)
);

CREATE TABLE user_skills (
  user_id   INT UNSIGNED NOT NULL,
  skill_id  INT UNSIGNED NOT NULL,
  level     ENUM('beginner', 'intermediate', 'advanced') NOT NULL DEFAULT 'beginner',
  PRIMARY KEY (user_id, skill_id),
  CONSTRAINT fk_user_skills_user FOREIGN KEY (user_id)
    REFERENCES users (user_id) ON DELETE CASCADE,
  CONSTRAINT fk_user_skills_skill FOREIGN KEY (skill_id)
    REFERENCES skills (skill_id) ON DELETE CASCADE
);

CREATE TABLE experiences (
  experience_id  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id        INT UNSIGNED NOT NULL,
  job_title      VARCHAR(100) NOT NULL,
  company_name   VARCHAR(150) NOT NULL,   -- texto livre: a empresa pode não estar cadastrada
  description    TEXT,
  start_date     DATE NOT NULL,
  end_date       DATE,                    -- NULL = emprego atual
  CONSTRAINT ck_experiences_dates CHECK (end_date IS NULL OR end_date >= start_date),
  CONSTRAINT fk_experiences_user FOREIGN KEY (user_id)
    REFERENCES users (user_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------
-- 4. CURSOS E MATRÍCULAS
-- ---------------------------------------------------------------------
CREATE TABLE courses (
  course_id        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  institution_id   INT UNSIGNED  NOT NULL,
  course_name      VARCHAR(150)  NOT NULL,
  description      TEXT,
  content          TEXT,
  duration_hours   INT UNSIGNED  NOT NULL,
  available_seats  INT UNSIGNED  NOT NULL DEFAULT 0,
  price            DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  CONSTRAINT ck_courses_price CHECK (price >= 0),
  CONSTRAINT fk_courses_institution FOREIGN KEY (institution_id)
    REFERENCES institutions (institution_id) ON DELETE CASCADE
);

CREATE TABLE enrollments (
  enrollment_id  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id        INT UNSIGNED NOT NULL,
  course_id      INT UNSIGNED NOT NULL,
  enrolled_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status         ENUM('active', 'completed', 'cancelled') NOT NULL DEFAULT 'active',
  CONSTRAINT uq_enrollments UNIQUE (user_id, course_id),   -- sem matrícula duplicada
  CONSTRAINT fk_enrollments_user FOREIGN KEY (user_id)
    REFERENCES users (user_id) ON DELETE CASCADE,
  CONSTRAINT fk_enrollments_course FOREIGN KEY (course_id)
    REFERENCES courses (course_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------
-- 5. VAGAS E CANDIDATURAS
-- ---------------------------------------------------------------------
CREATE TABLE jobs (
  job_id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  company_id     INT UNSIGNED NOT NULL,
  title          VARCHAR(150) NOT NULL,
  area           VARCHAR(80),
  location       VARCHAR(100) NOT NULL DEFAULT '',                    -- cidade
  work_mode      ENUM('Presencial', 'Híbrido', 'Remoto') NOT NULL DEFAULT 'Presencial',
  description    TEXT,
  contract_type  ENUM('clt', 'pj', 'internship', 'apprentice', 'temporary', 'freelance') NOT NULL,
  salary_min     DECIMAL(10,2),
  salary_max     DECIMAL(10,2),
  workload       VARCHAR(60),                                          -- carga horária, ex.: 40h semanais
  requirements   TEXT,                                                 -- requisitos
  benefits       TEXT,                                                 -- benefícios
  published_at   DATE NOT NULL DEFAULT (CURRENT_DATE),
  status         ENUM('open', 'paused', 'closed') NOT NULL DEFAULT 'open',
  CONSTRAINT ck_jobs_salary CHECK (salary_max IS NULL OR salary_min IS NULL OR salary_max >= salary_min),
  CONSTRAINT fk_jobs_company FOREIGN KEY (company_id)
    REFERENCES companies (company_id) ON DELETE CASCADE
);

CREATE TABLE applications (
  application_id  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id         INT UNSIGNED NOT NULL,
  job_id          INT UNSIGNED NOT NULL,
  applied_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status          ENUM('under_review', 'approved', 'rejected', 'withdrawn') NOT NULL DEFAULT 'under_review',
  CONSTRAINT uq_applications UNIQUE (user_id, job_id),   -- sem candidatura duplicada
  CONSTRAINT fk_applications_user FOREIGN KEY (user_id)
    REFERENCES users (user_id) ON DELETE CASCADE,
  CONSTRAINT fk_applications_job FOREIGN KEY (job_id)
    REFERENCES jobs (job_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------
-- 6. AVALIAÇÕES  (o usuário avalia UMA empresa OU UMA instituição)
--    O MySQL não permite ON DELETE CASCADE em colunas usadas num CHECK,
--    por isso company_id/institution_id usam RESTRICT.
-- ---------------------------------------------------------------------
CREATE TABLE reviews (
  review_id       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id         INT UNSIGNED NOT NULL,
  company_id      INT UNSIGNED NULL,
  institution_id  INT UNSIGNED NULL,
  rating          TINYINT UNSIGNED NOT NULL,
  comment         TEXT,
  reviewed_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT ck_reviews_rating CHECK (rating BETWEEN 1 AND 5),
  CONSTRAINT ck_reviews_target CHECK (
    (company_id IS NOT NULL AND institution_id IS NULL) OR
    (company_id IS NULL     AND institution_id IS NOT NULL)
  ),
  -- cada usuário avalia cada empresa/instituição uma única vez
  CONSTRAINT uq_reviews_company     UNIQUE (user_id, company_id),
  CONSTRAINT uq_reviews_institution UNIQUE (user_id, institution_id),
  CONSTRAINT fk_reviews_user FOREIGN KEY (user_id)
    REFERENCES users (user_id) ON DELETE CASCADE,
  CONSTRAINT fk_reviews_company FOREIGN KEY (company_id)
    REFERENCES companies (company_id),
  CONSTRAINT fk_reviews_institution FOREIGN KEY (institution_id)
    REFERENCES institutions (institution_id)
);

-- ---------------------------------------------------------------------
-- 7. MENSAGENS  (de uma conta para outra)
-- ---------------------------------------------------------------------
CREATE TABLE messages (
  message_id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  sender_id     INT UNSIGNED NOT NULL,
  receiver_id   INT UNSIGNED NOT NULL,
  message       TEXT NOT NULL,
  sent_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  is_read       BOOLEAN  NOT NULL DEFAULT FALSE,
  CONSTRAINT fk_messages_sender FOREIGN KEY (sender_id)
    REFERENCES accounts (account_id) ON DELETE CASCADE,
  CONSTRAINT fk_messages_receiver FOREIGN KEY (receiver_id)
    REFERENCES accounts (account_id) ON DELETE CASCADE,
  INDEX idx_messages_conversation (sender_id, receiver_id, sent_at)
);

-- ---------------------------------------------------------------------
-- 8. ÍNDICES para as buscas mais comuns do app
-- ---------------------------------------------------------------------
CREATE INDEX idx_jobs_status_area ON jobs (status, area);
CREATE INDEX idx_courses_name     ON courses (course_name);

-- =====================================================================
-- 9. USUÁRIO DO APP
--    O app Flutter NÃO conecta como root. Este usuário só lê/grava dados
--    (não pode criar nem apagar tabelas).
-- =====================================================================
DROP USER IF EXISTS 'Jobfy'@'localhost';
DROP USER IF EXISTS 'Jobfy'@'%';

-- Windows/desktop
CREATE USER 'Jobfy'@'localhost' IDENTIFIED BY 'Jobfy2026';
-- celular ou emulador na mesma rede Wi-Fi
CREATE USER 'Jobfy'@'%'         IDENTIFIED BY 'Jobfy2026';

GRANT SELECT, INSERT, UPDATE, DELETE ON jobfy.* TO 'Jobfy'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON jobfy.* TO 'Jobfy'@'%';
FLUSH PRIVILEGES;
