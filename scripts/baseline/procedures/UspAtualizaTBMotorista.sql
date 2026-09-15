-- ============================================================
-- BASELINE: dbo.UspAtualizaTBMotorista
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAtualizaTBMotorista]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspAtualizaTBMotorista] as 



select distinct usr_matricula
into #matricula
from (
    select 
    row_number() over (PARTITION by usr_matricula order by usr_cd_usuario desc) as row_num
    , * 
    from tb_usuario with(nolock)
    where 1=1
    and usr_in_ativo = 1
    and usr_in_plataforma = 2
    and ISNUMERIC(usr_matricula) = 1
    and usr_in_motorista = 1
    and cli_cd_codigo_cliente = 27
    -- and usr_matricula = 6013
) as a 
where row_num > 1

update tb_usuario 
set usr_in_ativo = 0
where usr_matricula in (select usr_matricula from #matricula);

drop table if exists #CTE_Motoristas;
    SELECT 
        ROW_NUMBER() OVER (ORDER BY usr.usr_cd_usuario DESC) AS RowNum,
        usr_cd_usuario,
        usr_nm_usuario,
        usr_ds_email,
        usr_in_ativo,
        usr_dt_nascimento,
        cli_cd_codigo_cliente,
        usr_ds_num_telefone,
        usr_matricula,
        usr_cd_tipo_contrato
        into #CTE_Motoristas
    FROM tb_usuario usr with(nolock)
    LEFT JOIN tb_motorista mot with(nolock)
        ON mot.mot_cd_usuario = usr.usr_cd_usuario
        AND usr.cli_cd_codigo_cliente = mot.mot_cd_cliente
    WHERE mot.mot_cd_usuario IS NULL 
        AND usr_in_motorista = 1
        AND usr_in_ativo = 1
       AND cli_cd_codigo_cliente not IN (7)
        AND usr_nm_usuario NOT LIKE '%otus%'
        AND usr_nm_usuario NOT LIKE '%teste%'
        AND usr_nm_usuario NOT LIKE '%flight%'
        AND usr_nm_usuario NOT LIKE '%user%'
        AND usr_nm_usuario NOT LIKE '%testador%'
        AND usr_nm_usuario NOT LIKE '%testando%'
        AND usr_ds_email NOT LIKE '%otus7%'


-- Etapa 2: Criar variáveis de controle
DECLARE @i INT = 1;
DECLARE @max INT;

-- Inicializar a variável @max após a CTE
SET @max = (SELECT COUNT(*) FROM #CTE_Motoristas);

-- Etapa 3: Loop de inserção
WHILE @i <= @max
BEGIN
    INSERT INTO tb_motorista (
        mot_cd_usuario,
        mot_nm_motorista,
        mot_cnt_vl_email,
        mot_cd_status,
        mot_dt_nascimento,
        mot_cd_cliente,
        mot_cnt_vl_celular,
        mot_cd_matricula,
        mot_ctn_cd_tipo_contrato
    )
    SELECT 
        usr_cd_usuario,
        usr_nm_usuario,
        usr_ds_email,
        usr_in_ativo,
        usr_dt_nascimento,
        cli_cd_codigo_cliente,
        usr_ds_num_telefone,
        usr_matricula,
        usr_cd_tipo_contrato
    FROM #CTE_Motoristas
    WHERE RowNum = @i;

    SET @i += 1;
END



-- crie um join para inserir tudo que esta na tb_motorista e nao esta na tb_usuario

insert into tb_usuario (
    usr_nm_usuario,
    usr_ds_email,
    usr_in_ativo,
    usr_dt_nascimento,
    cli_cd_codigo_cliente,
    usr_ds_num_telefone,
    usr_matricula,
    usr_cd_tipo_contrato,
    usr_ds_senha,
    usr_dh_criacao,
    usr_dh_modificacao,
    usr_in_registro_gps,
    usr_in_fat_motorista_valor_app
)

select 
    mot_nm_motorista,
    mot_cnt_vl_email,
    mot_cd_status,
    mot_dt_nascimento,
    mot_cd_cliente,
    mot_cnt_vl_celular,
    mot_cd_matricula,
    null mot_ctn_cd_tipo_contrato,
    '-' usr_ds_senha,
    getdate() as usr_dh_criacao,
    getdate() as usr_dh_modificacao,
     0 usr_in_registro_gps,
     0 usr_in_fat_motorista_valor_app

from tb_motorista mot with(nolock)
left join tb_usuario as usr with(nolock)
on usr.usr_ds_email = mot.mot_cnt_vl_email
    and mot.mot_cd_usuario = usr.usr_cd_usuario  -- Adiciona a verificação do código de usuário
			and usr.cli_cd_codigo_cliente = mot.mot_cd_cliente


-- and mot_nm_motorista = usr.usr_nm_usuario

where usr.usr_ds_email is null
    AND usr_cd_usuario IS NULL  -- Garante que o usuário também não está cadastrado
	and usr.cli_cd_codigo_cliente is null
and mot_cd_status = 1
and mot_cnt_vl_email is not null
and cli_cd_codigo_cliente <> 7;
--and usr_nm_usuario is null
GO
