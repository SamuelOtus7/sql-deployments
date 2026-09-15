-- ============================================================
-- BASELINE: dbo.fn_relatorio_situacao_cadastral
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_relatorio_situacao_cadastral]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_relatorio_situacao_cadastral](@ClienteId int ,@StatusAtivo int ) 
RETURNS TABLE
AS
RETURN


--select *  from fn_relatorio_situacao_cadastral(37,null)

---- Parâmetros (opcional): filtre status e/ou cliente
--DECLARE @StatusAtivo INT = 1;
---- Para todos os clientes, deixe @ClienteId = NULL
--DECLARE @ClienteId INT = 37; -- ex.: 61

WITH base AS (
    SELECT *
    FROM dbo.tb_motorista m
    WHERE (@StatusAtivo IS NULL OR m.mot_cd_status = @StatusAtivo)
      AND (@ClienteId  IS NULL OR m.mot_cd_cliente = @ClienteId)
      and mot_cnt_vl_email not like '%inativo%'
      and mot_cnt_vl_email not like '%DELETADO%'
),
-- Normalizador de "preenchido" para evitar repetir muita lógica:
-- Se for texto: NOT NULL e não vazio após TRIM
-- Se for numérico/data: NOT NULL já basta
prep AS (
    SELECT 
        m.mot_cd_motorista,
        m.mot_cd_cliente,
        case when mot_cd_status = 1 then 'Ativo' else 'Inativo' end [Situacao],
        v.grupo,
        v.coluna,
        mot_nm_motorista,
        v.preenchido
    FROM base AS m
    CROSS APPLY (VALUES

('Pessoal','Cargo',                     CASE WHEN m.mot_position              IS NULL THEN 0 ELSE 1 END),
('Pessoal','Setor',                     CASE WHEN m.mot_sector                IS NULL THEN 0 ELSE 1 END),
('Pessoal','CPF',                       CASE WHEN m.mot_cpf                   IS NULL THEN 0 ELSE 1 END),
('Pessoal','E-mail',                    CASE WHEN m.mot_cnt_vl_email          IS NULL THEN 0 ELSE 1 END),   
('Pessoal','Telefone celular',          CASE WHEN m.mot_cnt_vl_celular        IS NULL THEN 0 ELSE 1 END),
('Pessoal','Telefone secundário',       CASE WHEN m.mot_cnt_vl_telefone       IS NULL THEN 0 ELSE 1 END),
('Pessoal','Telefone emergência 1',     CASE WHEN m.mot_cnt_emg_vl_telefone   IS NULL THEN 0 ELSE 1 END),
('Pessoal','Telefone emergência 2',     CASE WHEN m.mot_cnt_emg_vl_celular    IS NULL THEN 0 ELSE 1 END),
('Pessoal','Nome contato emergência',   CASE WHEN m.mot_cnt_emg_nm_contato    IS NULL THEN 0 ELSE 1 END),
('Pessoal','Grau de parentesco',        CASE WHEN m.mot_cnt_emg_grau_parentesco IS NULL THEN 0 ELSE 1 END),

('Profissionais','Cliente transportadora', CASE WHEN m.mot_ds_empresa_nome_fantasia IS NULL THEN 0 ELSE 1 END),
('Profissionais','Service center/Hub',     CASE WHEN m.mot_nm_svc                 IS NULL THEN 0 ELSE 1 END),
('Profissionais','Tipo de contrato',       CASE WHEN m.mot_ctn_cd_tipo_contrato   IS NULL THEN 0 ELSE 1 END),
('Profissionais','Status do contrato',     CASE WHEN m.mot_ctn_in_status_contrato IS NULL THEN 0 ELSE 1 END),
('Profissionais','Nome do ajudante',       CASE WHEN m.mot_nm_ajudante            IS NULL THEN 0 ELSE 1 END),
('Profissionais','CPF do ajudante',        CASE WHEN m.mot_cpf_ajudante           IS NULL THEN 0 ELSE 1 END),
('Profissionais','Telefone principal',     CASE WHEN m.mot_contato_ajudante       IS NULL THEN 0 ELSE 1 END),
('Profissionais','Telefone secundário',    CASE WHEN m.mot_celular_ajudante       IS NULL THEN 0 ELSE 1 END),

('Bancários','Agência',                 CASE WHEN m.mot_pag_cd_agencia        IS NULL THEN 0 ELSE 1 END),
('Bancários','Conta',                   CASE WHEN m.mot_pag_cd_conta          IS NULL THEN 0 ELSE 1 END),
('Bancários','Tipo de conta',           CASE WHEN m.mot_pag_ds_tipo_conta     IS NULL THEN 0 ELSE 1 END),
('Bancários','CPF do titular',          CASE WHEN m.mot_pag_cpf_titular       IS NULL THEN 0 ELSE 1 END),
('Bancários','CNPJ do titular',         CASE WHEN m.mot_pag_cnpj_titular      IS NULL THEN 0 ELSE 1 END),
('Bancários','Tipo de chave PIX',       CASE WHEN m.mot_ds_pix_key_type       IS NULL THEN 0 ELSE 1 END),
('Bancários','Chave PIX',               CASE WHEN m.mot_ds_pix_key            IS NULL THEN 0 ELSE 1 END),
('Bancários','Tipo de pagamento',       CASE WHEN m.mot_pag_cd_tipo_pagamento IS NULL THEN 0 ELSE 1 END),
('Bancários','Tipo de envio',           CASE WHEN m.mot_pag_ds_tipo_envio     IS NULL THEN 0 ELSE 1 END),
('Bancários','Visualiza financeiro no app?', CASE WHEN m.usr_in_fat_motorista_valor_app IS NULL THEN 0 ELSE 1 END),

('GR Motorista','Nº CNH',                    CASE WHEN m.mot_gr_vl_cnh_motorista            IS NULL THEN 0 ELSE 1 END),
('GR Motorista','UF Emissão CNH',            CASE WHEN m.mot_gr_vl_estado_cnh_motorista     IS NULL THEN 0 ELSE 1 END),
('GR Motorista','Categoria CNH',             CASE WHEN m.mot_gr_nm_tipo_cnh_motorista       IS NULL THEN 0 ELSE 1 END),
('GR Motorista','Data emissão CNH',          CASE WHEN m.mot_gr_dt_primeira_cnh_motorista   IS NULL THEN 0 ELSE 1 END),
('GR Motorista','Validade CNH',              CASE WHEN m.mot_gr_dt_vencimento_cnh_motorista IS NULL THEN 0 ELSE 1 END),
('GR Motorista','RENACH',                    CASE WHEN m.mot_gr_vl_renach_cnh_motorista     IS NULL THEN 0 ELSE 1 END),
('GR Motorista','RG',                        CASE WHEN m.mot_gr_vl_rg_motorista             IS NULL THEN 0 ELSE 1 END),
('GR Motorista','UF RG',                     CASE WHEN m.mot_gr_nm_estado_rg_motorista      IS NULL THEN 0 ELSE 1 END),
('GR Motorista','Órgão emissor RG',          CASE WHEN m.mot_ds_orgao_emissor_rg            IS NULL THEN 0 ELSE 1 END),
('GR Motorista','Estado civil',              CASE WHEN m.mot_ds_estado_civil                IS NULL THEN 0 ELSE 1 END),
('GR Motorista','Data nascimento',           CASE WHEN m.mot_dt_nascimento                  IS NULL THEN 0 ELSE 1 END),
('GR Motorista','Nacionalidade',             CASE WHEN m.mot_ds_nacionalidade               IS NULL THEN 0 ELSE 1 END),
('GR Motorista','Nome do pai',               CASE WHEN m.mot_gr_nm_pai                      IS NULL THEN 0 ELSE 1 END),
('GR Motorista','Nome da mãe',               CASE WHEN m.mot_gr_nm_mae                      IS NULL THEN 0 ELSE 1 END),
('GR Motorista','CEP',                       CASE WHEN m.mot_end_vl_cep                     IS NULL THEN 0 ELSE 1 END),
('GR Motorista','Logradouro',                CASE WHEN m.mot_end_ds_rua                     IS NULL THEN 0 ELSE 1 END),
('GR Motorista','Número',                    CASE WHEN m.mot_end_vl_numero                  IS NULL THEN 0 ELSE 1 END),
('GR Motorista','Complemento',               CASE WHEN m.mot_end_ds_complemento             IS NULL THEN 0 ELSE 1 END),
('GR Motorista','Bairro',                    CASE WHEN m.mot_end_nm_bairro                  IS NULL THEN 0 ELSE 1 END),
('GR Motorista','Cidade',                    CASE WHEN m.mot_end_nm_cidade                  IS NULL THEN 0 ELSE 1 END),
('GR Motorista','Estado',                    CASE WHEN m.mot_end_nm_estado                  IS NULL THEN 0 ELSE 1 END),
('GR Motorista','Cód. Município IBGE',       CASE WHEN m.mot_end_vl_cd_ibge                 IS NULL THEN 0 ELSE 1 END),
('GR Motorista','Empresa própria',           CASE WHEN m.mot_emp_in_propria                 IS NULL THEN 0 ELSE 1 END),
('GR Motorista','Tipo de empresa',           CASE WHEN m.mot_emp_ds_tipo                    IS NULL THEN 0 ELSE 1 END),
('GR Motorista','Razão social',              CASE WHEN m.mot_ds_empresa_razao_social        IS NULL THEN 0 ELSE 1 END),
('GR Motorista','CNPJ',                      CASE WHEN m.mot_ds_empresa_cnpj                IS NULL THEN 0 ELSE 1 END),
('GR Motorista','Insc. estadual',            CASE WHEN m.mot_ds_empresa_insc_estadual       IS NULL THEN 0 ELSE 1 END),
('GR Motorista','Insc. municipal',           CASE WHEN m.mot_ds_empresa_insc_municipal      IS NULL THEN 0 ELSE 1 END),
('GR Motorista','Representante legal',       CASE WHEN m.mot_ds_empresa_contato_nome        IS NULL THEN 0 ELSE 1 END),
('GR Motorista','Cargo representante',       CASE WHEN m.mot_ds_empresa_contato_cargo       IS NULL THEN 0 ELSE 1 END),
('GR Motorista','CPF representante',         CASE WHEN m.mot_ds_empresa_contato_cpf         IS NULL THEN 0 ELSE 1 END),
('GR Motorista','RG representante',          CASE WHEN m.mot_ds_empresa_contato_rg          IS NULL THEN 0 ELSE 1 END),
('GR Motorista','RG Órgão emissor',          CASE WHEN m.mot_ds_empresa_contato_emissor_rg  IS NULL THEN 0 ELSE 1 END),
('GR Motorista','E-mail de contato',         CASE WHEN m.mot_ds_empresa_contato_email       IS NULL THEN 0 ELSE 1 END),
('GR Motorista','Telefone principal',        CASE WHEN m.mot_ds_empresa_contato_telefone    IS NULL THEN 0 ELSE 1 END),
('GR Motorista','Telefone secundário',       CASE WHEN m.mot_ds_empresa_contato_celular     IS NULL THEN 0 ELSE 1 END),

('GR Veículo','Marca',                  CASE WHEN m.mot_ds_marca_veiculo          IS NULL THEN 0 ELSE 1 END),
('GR Veículo','Modelo',                 CASE WHEN m.mot_ds_modelo_veiculo         IS NULL THEN 0 ELSE 1 END),
('GR Veículo','Ano',                    CASE WHEN m.mot_cd_vehicle_year           IS NULL THEN 0 ELSE 1 END),
('GR Veículo','Placa',                  CASE WHEN m.mot_ds_plate                  IS NULL THEN 0 ELSE 1 END),
('GR Veículo','Tipo de veículo',        CASE WHEN m.mot_ds_vehicle_type           IS NULL THEN 0 ELSE 1 END),


('Outros','Status transportador',       CASE WHEN m.mot_ds_status_integracao_transportador IS NULL THEN 0 ELSE 1 END),
('Outros','Status motorista',           CASE WHEN m.mot_ds_status_integracao_motorista     IS NULL THEN 0 ELSE 1 END),
('Outros','Código Target',              CASE WHEN m.mot_cd_vehicle_codigo_target           IS NULL THEN 0 ELSE 1 END),
('Outros','Número do cartão',           CASE WHEN m.mot_cd_numero_cartao                   IS NULL THEN 0 ELSE 1 END),
('Outros','RNTRC',                      CASE WHEN m.mot_ds_vehicle_rntrc                   IS NULL THEN 0 ELSE 1 END),
('Outros','PIS/PASEP',                  CASE WHEN m.mot_pis_pasep                          IS NULL THEN 0 ELSE 1 END)

-- (inclua aqui os demais campos do veículo que você tiver mapeado, seguindo o mesmo padrão)



        -- >>>> Para adicionar mais campos, continue adicionando linhas aqui,
        -- sempre informando ('Grupo','nome_coluna', CASE WHEN ... THEN 1 ELSE 0 END)
    ) AS v(grupo, coluna, preenchido)
),
agg AS (
    SELECT 
        mot_cd_motorista,
        mot_cd_cliente,
        grupo,
        coluna,
        [Situacao],
        mot_nm_motorista,
        COUNT(*)                     AS campos_totais,
        SUM(preenchido)              AS campos_preenchidos,
        CAST(SUM(preenchido) * 100.0 / NULLIF(COUNT(*),0) AS DECIMAL(5,2)) AS pct_preenchimento
    FROM prep
    GROUP BY mot_cd_motorista, mot_cd_cliente, grupo,coluna,mot_nm_motorista,[Situacao]
)
SELECT 
    CASE 
        WHEN grupo IN ('Veículo','Endereço','Contatos','CNH/Docs','Pessoal','Contrato','Pagamento') 
            THEN 'Prioritário'
        ELSE 'Complementar' end Categoria_Cadastro ,* 
FROM agg
--ORDER BY mot_cd_cliente;
GO
