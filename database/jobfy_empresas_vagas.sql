-- =====================================================================
--  JOBFY - Empresas e vagas
--  SGBD: MySQL 8.0.16+ (MySQL Workbench - Local instance)
--
--  Rode o script inteiro logado como ROOT.
--  Ele NÃO apaga nada: mantém os bancos, tabelas, contas e vagas que já
--  existem e só adiciona o que estiver faltando. Pode ser rodado mais de
--  uma vez.
--
--  O que ele garante:
--    - tabela accounts (a empresa faz login por ela)
--    - tabela companies, com os dados do cadastro por CNPJ
--    - tabela jobs, com os campos do formulário de vaga
--    - usuário 'Jobfy', que o app usa para conectar
--    - 4 empresas e 4 vagas de exemplo (senha das contas: jobfy123)
--
--  Banco totalmente novo: use o jobfy_banco_completo.txt, que também cria
--  as tabelas de usuários, cursos e candidaturas.
-- =====================================================================

SET NAMES utf8mb4;

CREATE DATABASE IF NOT EXISTS jobfy
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE jobfy;

-- ---------------------------------------------------------------------
-- 1. TABELAS
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS accounts (
  account_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  email          VARCHAR(150) NOT NULL,
  password_hash  VARCHAR(255) NOT NULL,
  account_type   ENUM('user', 'company', 'institution') NOT NULL,
  is_active      BOOLEAN      NOT NULL DEFAULT TRUE,   -- FALSE = conta excluída/desativada
  created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_accounts_email UNIQUE (email)
);

CREATE TABLE IF NOT EXISTS companies (
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

CREATE TABLE IF NOT EXISTS jobs (
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
  published_at   DATE NOT NULL DEFAULT (CURRENT_DATE),
  status         ENUM('open', 'paused', 'closed') NOT NULL DEFAULT 'open',
  CONSTRAINT ck_jobs_salary CHECK (salary_max IS NULL OR salary_min IS NULL OR salary_max >= salary_min),
  CONSTRAINT fk_jobs_company FOREIGN KEY (company_id)
    REFERENCES companies (company_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------
-- 2. COLUNAS NOVAS, para quem já tinha essas tabelas de antes
--    Cada bloco só altera a tabela se a coluna ainda não existir.
-- ---------------------------------------------------------------------
SET @missing := (
  SELECT COUNT(*) = 0 FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = 'jobfy' AND TABLE_NAME = 'companies' AND COLUMN_NAME = 'trade_name'
);
SET @ddl := IF(@missing,
  'ALTER TABLE companies
     ADD COLUMN trade_name    VARCHAR(150) NULL AFTER company_name,
     ADD COLUMN business_area VARCHAR(200) NULL AFTER phone,
     ADD COLUMN zip_code      CHAR(8)      NULL AFTER business_area,
     ADD COLUMN address       VARCHAR(200) NULL AFTER zip_code,
     ADD COLUMN city          VARCHAR(100) NULL AFTER address,
     ADD COLUMN state         CHAR(2)      NULL AFTER city,
     ADD COLUMN description   TEXT         NULL AFTER state,
     ADD CONSTRAINT ck_companies_zip CHECK (zip_code IS NULL OR zip_code REGEXP ''^[0-9]{8}$'')',
  'DO 0');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @missing := (
  SELECT COUNT(*) = 0 FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = 'jobfy' AND TABLE_NAME = 'jobs' AND COLUMN_NAME = 'location'
);
SET @ddl := IF(@missing,
  'ALTER TABLE jobs ADD COLUMN location VARCHAR(100) NOT NULL DEFAULT '''' AFTER area',
  'DO 0');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @missing := (
  SELECT COUNT(*) = 0 FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = 'jobfy' AND TABLE_NAME = 'jobs' AND COLUMN_NAME = 'work_mode'
);
SET @ddl := IF(@missing,
  'ALTER TABLE jobs ADD COLUMN work_mode ENUM(''Presencial'', ''Híbrido'', ''Remoto'')
     NOT NULL DEFAULT ''Presencial'' AFTER location',
  'DO 0');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @missing := (
  SELECT COUNT(*) = 0 FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = 'jobfy' AND TABLE_NAME = 'jobs' AND COLUMN_NAME = 'salary_min'
);
SET @ddl := IF(@missing,
  'ALTER TABLE jobs
     ADD COLUMN salary_min DECIMAL(10,2) NULL AFTER contract_type,
     ADD COLUMN salary_max DECIMAL(10,2) NULL AFTER salary_min,
     ADD CONSTRAINT ck_jobs_salary CHECK (salary_max IS NULL OR salary_min IS NULL OR salary_max >= salary_min)',
  'DO 0');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ---------------------------------------------------------------------
-- 3. USUÁRIO DO APP
--    Só é criado se não existir; quem já existe mantém a senha.
-- ---------------------------------------------------------------------
-- Windows/desktop
CREATE USER IF NOT EXISTS 'Jobfy'@'localhost' IDENTIFIED BY 'Jobfy2026';
-- celular ou emulador na mesma rede Wi-Fi
CREATE USER IF NOT EXISTS 'Jobfy'@'%'         IDENTIFIED BY 'Jobfy2026';

GRANT SELECT, INSERT, UPDATE, DELETE ON jobfy.* TO 'Jobfy'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON jobfy.* TO 'Jobfy'@'%';
FLUSH PRIVILEGES;

-- ---------------------------------------------------------------------
-- 4. EMPRESAS DE EXEMPLO
--    INSERT IGNORE pula o que já existe (e-mail ou CNPJ repetido).
-- ---------------------------------------------------------------------
SET @pwd := '$2a$10$HbfKb4.g./GSm9vdBaFSI.ifyLx8eFtGqZS/XoRJmHoTglZ/hKdWO';  -- jobfy123

INSERT IGNORE INTO accounts (email, password_hash, account_type) VALUES
  ('rh@technova.com.br',            @pwd, 'company'),
  ('vagas@verdeagro.com.br',        @pwd, 'company'),
  ('rh@conectatelecom.com.br',      @pwd, 'company'),
  ('talentos@pixelcriativo.com.br', @pwd, 'company');

INSERT IGNORE INTO companies (account_id, company_name, cnpj, phone)
SELECT a.account_id, s.company_name, s.cnpj, s.phone
FROM (
  SELECT 'rh@technova.com.br' AS email, 'TechNova Soluções Digitais' AS company_name,
         '31457892000115' AS cnpj, '(11) 4003-2211' AS phone
  UNION ALL SELECT 'vagas@verdeagro.com.br', 'Verde Agro Analytics',
         '27684153000190', '(19) 3254-8870'
  UNION ALL SELECT 'rh@conectatelecom.com.br', 'Conecta Telecom',
         '63920417000158', '(31) 3047-6612'
  UNION ALL SELECT 'talentos@pixelcriativo.com.br', 'Pixel Criativo Studio',
         '45139786000127', '(41) 3598-4420'
) AS s
JOIN accounts a ON a.email = s.email;

-- ---------------------------------------------------------------------
-- 5. VAGAS DE EXEMPLO
--    Só entra a vaga que a empresa ainda não tem com esse título.
-- ---------------------------------------------------------------------
INSERT INTO jobs (company_id, title, area, location, work_mode, description,
                  contract_type, salary_min, salary_max, published_at, status)
SELECT c.company_id, s.title, s.area, s.location, s.work_mode, s.description,
       s.contract_type, s.salary_min, s.salary_max, s.published_at, 'open'
FROM (
  SELECT '31457892000115' AS cnpj, 'Desenvolvedor(a) Flutter Pleno' AS title,
         'Tecnologia' AS area, 'São Paulo, SP' AS location, 'Remoto' AS work_mode,
         'Buscamos desenvolvedor(a) Flutter para evoluir nosso app de gestão financeira. Requisitos: 2+ anos com Flutter/Dart, consumo de APIs REST e Git. Diferencial: testes automatizados.' AS description,
         'clt' AS contract_type, 7000.00 AS salary_min, 10000.00 AS salary_max,
         CURRENT_DATE - INTERVAL 2 DAY AS published_at
  UNION ALL SELECT '27684153000190', 'Analista de Dados Júnior',
         'Dados', 'Campinas, SP', 'Híbrido',
         'Atuação na análise de dados de produtividade agrícola, criação de dashboards e relatórios. Requisitos: SQL, Excel avançado e noções de Python.',
         'clt', 4500.00, 6500.00, CURRENT_DATE - INTERVAL 5 DAY
  UNION ALL SELECT '63920417000158', 'Estágio em Suporte de TI',
         'Tecnologia', 'Belo Horizonte, MG', 'Presencial',
         'Estágio para atendimento a usuários, instalação de softwares e manutenção de computadores. Requisitos: cursando TI ou áreas afins, boa comunicação. Bolsa + vale-transporte.',
         'internship', 1500.00, 1800.00, CURRENT_DATE - INTERVAL 1 DAY
  UNION ALL SELECT '45139786000127', 'Designer UX/UI',
         'Design', 'Curitiba, PR', 'Remoto',
         'Criação de interfaces para apps e sites de clientes, protótipos no Figma e testes de usabilidade. Requisitos: portfólio, Figma e noções de design responsivo.',
         'pj', 6000.00, 9000.00, CURRENT_DATE - INTERVAL 7 DAY
) AS s
JOIN companies c ON c.cnpj = s.cnpj
WHERE NOT EXISTS (
  SELECT 1 FROM jobs j WHERE j.company_id = c.company_id AND j.title = s.title
);

COMMIT;

-- ---------------------------------------------------------------------
-- 6. CONFERÊNCIA: lista as vagas como o app mostra
-- ---------------------------------------------------------------------
SELECT
  j.job_id                        AS id,
  j.title,
  c.company_name                  AS company,
  j.location,
  j.work_mode                     AS type,
  CONCAT('R$ ', FORMAT(j.salary_min, 0, 'de_DE'),
         ' - ', FORMAT(j.salary_max, 0, 'de_DE')) AS salary
FROM jobs j
JOIN companies c ON c.company_id = j.company_id
WHERE j.status = 'open'
ORDER BY j.published_at DESC, j.job_id DESC;
