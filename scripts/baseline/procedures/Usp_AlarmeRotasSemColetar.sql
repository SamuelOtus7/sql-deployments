-- ============================================================
-- BASELINE: dbo.Usp_AlarmeRotasSemColetar
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeRotasSemColetar]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Usp_AlarmeRotasSemColetar] as 

Declare @dataref date = getdate()
		 ,@QTDref int = 1
		 ,@QTDParada int

drop table if exists #tabela
SELECT 
	cli_ds_nome
	,cmt_cd_transportadora
	--,dateadd(hh,-3,max(cmt_dh_coleta)) as UltimaAtualizacao
	,datediff(minute,dateadd(hh,-3,max(cmt_dh_coleta)),getdate()) as MinutosSemColetar
	--,datediff(minute,max(cmt_dh_escrita),getdate()) as MinutosSemEscrever
into #tabela
FROM 
	db_Irisys_Json.dbo.tb_ml_coleta_totalizador as a WITH (ROWLOCK, READPAST, UPDLOCK)
	left join tb_clientes as b
	on cmt_cd_transportadora = cli_id_logistics
WHERE 
	cmt_dh_referencia >= '2025-03-25'
	and cli_in_ativo = 1
	and cli_ds_nome not in ('Otus7','Eco Express','Torres Transportes','Pralog','Avista','ALC Transportes','Flashlog')
	--and cmr_in_processado = 1 
	--and cmr_cd_transportadora = 678279205
group by cli_ds_nome,cmt_cd_transportadora
order by 3

select @QTDParada = (
	select count(*) from #tabela where MinutosSemColetar > 10
)

--select * from #tabela
--where MinutosSemColetar > 10



	IF  @QTDParada >= @QTDref
BEGIN
    DECLARE @coleta VARCHAR(1000);
    DECLARE @mensagem VARCHAR(2000);

    SELECT  @coleta = SUBSTRING( 
      ( 
        SELECT CHAR(10) + cli_ds_nome +  char(10)+ char(10) AS 'data()' 
        FROM #tabela 
		where MinutosSemColetar > 10
        FOR XML PATH('') 
    ), 2 , 9999);

    SET @mensagem = 'Os clientes abaixo estão sem coletar rotas a mais de 15 minutos: '+  CHAR(10) +  CHAR(10) 
        + @coleta  +  CHAR(10) +  CHAR(10)
--select @mensagem
    RAISERROR(@mensagem, 16, 1);

END
GO
