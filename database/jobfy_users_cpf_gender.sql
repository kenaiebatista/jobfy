-- =====================================================================
--  Jobfy: adiciona CPF e gênero na tabela `users`
--  (a tela de cadastro pede os dois campos).
--  Rode logado como root (o usuário 'Jobfy' não tem permissão de ALTER).
--  Pode ser rodado mais de uma vez: só adiciona se ainda não existir.
-- =====================================================================

USE jobfy;

SET @missing := (
  SELECT COUNT(*) = 0 FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = 'jobfy' AND TABLE_NAME = 'users' AND COLUMN_NAME = 'cpf'
);
SET @ddl := IF(@missing,
  'ALTER TABLE users
     ADD COLUMN cpf    CHAR(11) NULL AFTER name,           -- só números
     ADD COLUMN gender ENUM(''male'', ''female'', ''other'') NULL AFTER cpf,
     ADD CONSTRAINT uq_users_cpf UNIQUE (cpf),
     ADD CONSTRAINT ck_users_cpf CHECK (cpf IS NULL OR cpf REGEXP ''^[0-9]{11}$'')',
  'DO 0');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Confere o resultado: devem aparecer as colunas cpf e gender.
SHOW COLUMNS FROM users;
