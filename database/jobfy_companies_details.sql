-- =====================================================================
--  Jobfy: dados completos da empresa na tabela `companies`
--  (os campos que a tela de cadastro preenche pela BrasilAPI).
--  Rode logado como root (o usuário 'Jobfy' não tem permissão de ALTER).
--  Pode ser rodado mais de uma vez: só adiciona se ainda não existir.
--
--  company_name continua sendo a razão social.
-- =====================================================================

USE jobfy;

SET @missing := (
  SELECT COUNT(*) = 0 FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = 'jobfy' AND TABLE_NAME = 'companies' AND COLUMN_NAME = 'trade_name'
);
SET @ddl := IF(@missing,
  'ALTER TABLE companies
     ADD COLUMN trade_name    VARCHAR(150) NULL AFTER company_name,  -- nome fantasia
     ADD COLUMN business_area VARCHAR(200) NULL AFTER phone,         -- atividade principal (CNAE)
     ADD COLUMN zip_code      CHAR(8)      NULL AFTER business_area, -- CEP, só números
     ADD COLUMN address       VARCHAR(200) NULL AFTER zip_code,      -- rua, número, bairro
     ADD COLUMN city          VARCHAR(100) NULL AFTER address,
     ADD COLUMN state         CHAR(2)      NULL AFTER city,          -- UF
     ADD COLUMN description   TEXT         NULL AFTER state,         -- sobre a empresa
     ADD CONSTRAINT ck_companies_zip CHECK (zip_code IS NULL OR zip_code REGEXP ''^[0-9]{8}$'')',
  'DO 0');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Confere o resultado: devem aparecer as colunas novas.
SHOW COLUMNS FROM companies;