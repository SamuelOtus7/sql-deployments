-- ============================================================
-- BASELINE: dbo.Usp_AlarmeMotoristasAprovacao
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeMotoristasAprovacao]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_AlarmeMotoristasAprovacao] as 

Declare @dataref date = getdate()
	
DROP TABLE IF EXISTS #base;
select
	c.cli_ds_nome 
	,dac_cd_transportadora IdTransportadora
	,dateadd(hour,-3,max(dac_dh_coleta)) as UltimaColeta

		  INTO #base

from 
	db_Irisys_Json.dbo.tb_dra_coleta d with(nolock) 
	join tb_clientes c with(nolock) on d.dac_cd_transportadora = c.cli_id_logistics and cli_in_ativo=1 and cli_in_excluido = 0
where 
	dac_ds_tipo_coleta = 'DRIVER_ML'
	and c.cli_ds_nome not in ( 'Avista','ALC Transportes','Otus7','Flashlog')
group by
	c.cli_ds_nome
	,dac_cd_transportadora
having
	dateadd(hour,-3,max(dac_dh_coleta)) < dateadd(hour, -20, getdate())
order by
	3 desc



		
IF EXISTS (SELECT 1 FROM #base)
BEGIN
    DECLARE @msg NVARCHAR(MAX) = '';

    SELECT @msg = COALESCE(@msg + CHAR(10), '') + 'Cliente: ' + cli_ds_nome + ', Ultima Coleta: ' + CONVERT(VARCHAR(20), UltimaColeta, 103 ) + ' ' + CONVERT(varchar(8), UltimaColeta, 108)  + CHAR(10)
    FROM #base;


    RAISERROR ('A coleta de motoristas para a tela de aprovação está sem atualizar há mais de 6 hora sem coletar dados, favor verificar com time de desenvolvimenteo se o job "DRIVER_ML" esta ativo:  %s%s', 16, 1, @msg);
END
ELSE
BEGIN
    PRINT 'OK';
END;


GO
