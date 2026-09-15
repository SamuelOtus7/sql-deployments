-- ============================================================
-- BASELINE: dbo.Usp_AlarmeScraperParadoTransportadora
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeScraperParadoTransportadora]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Usp_AlarmeScraperParadoTransportadora] as 



DROP TABLE IF EXISTS #aux;
CREATE TABLE #aux (
    ds_nome VARCHAR(50) NOT NULL,
    cd_transportadora VARCHAR(20) NULL,
    UltimaAtualizacao datetime NOT NULL,
	UltimaAtualizacaoDif int NOT NULL
)

INSERT INTO #aux
SELECT 
	cli_ds_nome + ',' as cli_ds_nome
	,cmt_cd_transportadora
	,dateadd(hh,-3,max(cmt_dh_coleta)) as UltimaAtualizacao
	,datediff(minute,dateadd(hh,-3,max(cmt_dh_coleta)),getdate()) as UltimaAtualizacaoDif
 
FROM 
	db_Irisys_Json.dbo.tb_ml_coleta_totalizador as a WITH (ROWLOCK, READPAST, UPDLOCK)
	inner join tb_clientes as b
	on cmt_cd_transportadora = cli_id_logistics
WHERE 
	cmt_dh_referencia >= '2025-02-07'
	and cli_in_ativo = 1
	and cli_ds_nome <> 'Otus7'
	and cmt_in_processado = 1 
	--and cmt_cd_transportadora = 678279205
group by cli_ds_nome,cmt_cd_transportadora	
having datediff(minute,dateadd(hh,-3,max(cmt_dh_coleta)),getdate()) > 10
 
 
IF EXISTS (SELECT * 
			 FROM #aux
			WHERE UltimaAtualizacaoDif > 10)
BEGIN
    DECLARE @coleta VARCHAR(1000);
    DECLARE @mensagem VARCHAR(2000);
	
  SELECT @coleta = SUBSTRING( 
    ( 
        SELECT CHAR(10) + ds_nome 
        FROM #aux 
        FOR XML PATH('') 
    ), 2 , 9999);

    SET @mensagem =  'Os clientes abaixo estão mais de 10 minutos sem receber atualizações de rotas na tabela db_Irisys_Json.dbo.tb_ml_coleta_totalizador: ' +  CHAR(10) +  CHAR(10) 
        + @coleta + ' Necessário verificação.'
  
 -- select @mensagem
  RAISERROR(@mensagem, 16, 1);

END;
 

GO
