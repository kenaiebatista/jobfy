-- =====================================================================
--  JOBFY - Detalhes das vagas e candidaturas
--  SGBD: MySQL 8.0.16+ (MySQL Workbench - Local instance)
--
--  Rode o script inteiro logado como ROOT (o usuário 'Jobfy' não tem
--  permissão de ALTER). Ele NÃO apaga nada e pode ser rodado mais de uma
--  vez: só adiciona o que estiver faltando.
--
--  O que ele faz:
--    - jobs: colunas workload (carga horária), requirements (requisitos)
--      e benefits (benefícios), mostradas nos detalhes da vaga
--    - applications: garante a tabela das candidaturas
--    - preenche os novos campos das 4 vagas de exemplo
--    - cria uma candidata de exemplo inscrita em 2 vagas
--      (login: ana.souza@email.com / jobfy123)
-- =====================================================================

SET NAMES utf8mb4;

USE jobfy;

-- ---------------------------------------------------------------------
-- 1. NOVAS COLUNAS EM jobs (só se ainda não existirem)
-- ---------------------------------------------------------------------
SET @missing := (
  SELECT COUNT(*) = 0 FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = 'jobfy' AND TABLE_NAME = 'jobs' AND COLUMN_NAME = 'workload'
);
SET @ddl := IF(@missing,
  'ALTER TABLE jobs
     ADD COLUMN workload     VARCHAR(60) NULL AFTER salary_max,   -- carga horária, ex.: 40h semanais
     ADD COLUMN requirements TEXT        NULL AFTER workload,     -- requisitos
     ADD COLUMN benefits     TEXT        NULL AFTER requirements  -- benefícios',
  'DO 0');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ---------------------------------------------------------------------
-- 2. CANDIDATURAS (já existe no banco completo; criada se faltar)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS applications (
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
-- 3. DETALHES DAS VAGAS DE EXEMPLO
--    Só preenche a vaga que ainda não tem requisitos.
-- ---------------------------------------------------------------------
UPDATE jobs j
JOIN companies c ON c.company_id = j.company_id
JOIN (
  SELECT '31457892000115' AS cnpj, 'Desenvolvedor(a) Flutter Pleno' AS title,
         '40h semanais, seg. a sex.' AS workload,
         '2+ anos com Flutter/Dart, consumo de APIs REST e Git. Diferencial: testes automatizados.' AS requirements,
         'Vale-refeição, plano de saúde e auxílio home office.' AS benefits
  UNION ALL SELECT '27684153000190', 'Analista de Dados Júnior',
         '40h semanais, 3 dias no escritório',
         'SQL, Excel avançado e noções de Python.',
         'Vale-transporte, vale-refeição e plano odontológico.'
  UNION ALL SELECT '63920417000158', 'Estágio em Suporte de TI',
         '30h semanais (6h por dia)',
         'Cursando TI ou áreas afins, boa comunicação.',
         'Bolsa-auxílio e vale-transporte.'
  UNION ALL SELECT '45139786000127', 'Designer UX/UI',
         'Flexível, cerca de 40h semanais',
         'Portfólio, Figma e noções de design responsivo.',
         'Horário flexível e equipamento fornecido pela empresa.'
) AS s ON s.cnpj = c.cnpj AND s.title = j.title
SET j.workload = s.workload,
    j.requirements = s.requirements,
    j.benefits = s.benefits
WHERE j.requirements IS NULL;

-- ---------------------------------------------------------------------
-- 4. CANDIDATA DE EXEMPLO
--    INSERT IGNORE pula o que já existe (e-mail ou CPF repetido).
-- ---------------------------------------------------------------------
SET @pwd := '$2a$10$HbfKb4.g./GSm9vdBaFSI.ifyLx8eFtGqZS/XoRJmHoTglZ/hKdWO';  -- jobfy123

INSERT IGNORE INTO accounts (email, password_hash, account_type)
VALUES ('ana.souza@email.com', @pwd, 'user');

INSERT IGNORE INTO users (account_id, name, cpf, gender, birth_date, phone, education_level)
SELECT account_id, 'Ana Clara Souza', '52998224725', 'female', '2007-03-15',
       '(47) 99876-5432', 'high_school_complete'
FROM accounts WHERE email = 'ana.souza@email.com';

SET @usr_ana := (
  SELECT u.user_id FROM users u
  JOIN accounts a ON a.account_id = u.account_id
  WHERE a.email = 'ana.souza@email.com'
);

INSERT IGNORE INTO skills (name) VALUES ('Flutter'), ('Dart'), ('Git');

INSERT IGNORE INTO user_skills (user_id, skill_id, level)
SELECT @usr_ana, skill_id, 'intermediate' FROM skills
WHERE @usr_ana IS NOT NULL AND name IN ('Flutter', 'Dart', 'Git');

INSERT INTO experiences (user_id, job_title, company_name, description, start_date, end_date)
SELECT @usr_ana, 'Monitora de informática (voluntária)', 'Escola Estadual Gaspar',
       'Ajudava alunos e professores no laboratório de informática.', '2024-02-01', '2025-12-15'
FROM DUAL
WHERE @usr_ana IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM experiences WHERE user_id = @usr_ana);

-- uq_applications impede a mesma candidatura duas vezes.
INSERT IGNORE INTO applications (user_id, job_id)
SELECT @usr_ana, job_id FROM jobs
WHERE @usr_ana IS NOT NULL
  AND title IN ('Desenvolvedor(a) Flutter Pleno', 'Estágio em Suporte de TI');

COMMIT;

-- ---------------------------------------------------------------------
-- 5. CONFERÊNCIA: vagas com detalhes e quantidade de candidatos
-- ---------------------------------------------------------------------
SELECT
  j.job_id      AS id,
  j.title,
  c.company_name AS company,
  j.workload,
  j.requirements,
  (SELECT COUNT(*) FROM applications ap WHERE ap.job_id = j.job_id) AS candidates
FROM jobs j
JOIN companies c ON c.company_id = j.company_id
ORDER BY j.published_at DESC, j.job_id DESC;
