-- ============================================================
-- BASELINE: dbo.CARREGA_ESCALA_MOTORISTA_BKUP
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[CARREGA_ESCALA_MOTORISTA_BKUP]    Script Date: 14/09/2026 12:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[CARREGA_ESCALA_MOTORISTA_BKUP] 
as

drop table if exists #tabela

DECLARE @qtddia INT = 3;
WITH DateGenerator AS (
    SELECT 0 AS DayIncrement
    UNION ALL
    SELECT DayIncrement + 1
    FROM DateGenerator
    WHERE DayIncrement + 1 < @qtddia
)

SELECT  
    DATEADD(DAY, dg.DayIncrement, cast(GETDATE() as date)) AS em_data_referencia,
    usr_cd_usuario AS em_cd_motorista,
    '-' AS em_ds_placa,
    '-' AS em_ds_tipo,
    'F' AS em_ds_frota,
'37' AS em_cd_base,
    '-' AS em_ds_ciclo,
    'Indisponível' AS em_ds_escala,
    usr_cd_usuario AS em_cd_usuario_escala,
    GETDATE() AS em_dh_escala,
    cli_cd_codigo_cliente as em_cd_cliente

    into #tabela 

--FROM tb_usuario, DateGenerator dg
From tb_usuario 
cross join DateGenerator dg
WHERE usr_in_ativo = 1 
AND cli_cd_codigo_cliente <> 7  
OPTION (MAXRECURSION 0);

--select * from #tabela
-- crie um merge para atualizar os dados da tabela tb_escala_motorista
-- com os dados da tabela #tabela

merge tb_escala_motorista as target
using #tabela as source
on target.em_data_referencia = source.em_data_referencia
and target.em_cd_motorista = source.em_cd_motorista and source.em_cd_cliente is not null

when matched then
    update set 
        target.em_ds_placa = source.em_ds_placa,
        target.em_ds_tipo = source.em_ds_tipo,
        target.em_ds_frota = source.em_ds_frota,
        target.em_ds_ciclo = source.em_ds_ciclo,
        target.em_ds_escala = source.em_ds_escala,
        target.em_cd_usuario_escala = source.em_cd_usuario_escala
      --  target.em_dh_escala = source.em_dh_escala

when not matched then
    insert (em_data_referencia, em_cd_motorista, em_ds_placa, em_ds_tipo, em_ds_frota, em_cd_base, em_ds_ciclo, em_ds_escala, em_cd_usuario_escala, em_dh_escala, em_cd_cliente)
    values (source.em_data_referencia, source.em_cd_motorista, source.em_ds_placa, source.em_ds_tipo, source.em_ds_frota, source.em_cd_base, source.em_ds_ciclo, source.em_ds_escala, source.em_cd_usuario_escala, source.em_dh_escala, source.em_cd_cliente);
	
	
GO
