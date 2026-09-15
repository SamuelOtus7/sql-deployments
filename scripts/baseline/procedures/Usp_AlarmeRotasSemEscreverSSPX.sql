-- ============================================================
-- BASELINE: dbo.Usp_AlarmeRotasSemEscreverSSPX
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeRotasSemEscreverSSPX]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_AlarmeRotasSemEscreverSSPX] as 

Declare @dataref date = getdate()
		 ,@QTDref int = 1
		 ,@QTDParada int

drop table if exists #tabela
SELECT 
	cli_ds_nome
	,dac_cd_transportadora
	,datediff(minute,max(dac_dh_escrita),getdate()) as MinutosSemEscrever
into #tabela
from db_Irisys_Json.dbo.tb_dra_coleta a
 join tb_clientes b
on a.dac_cd_transportadora = b.cli_id_shopee
join vw_spe_pacotes_reprocessar c
on a.dac_cd_transportadora = c.Idtransportadora
WHERE 
	 cli_in_ativo = 1
	and cli_ds_nome not in( 'Otus7','Pralog','Torres Transportes','Eco Express','Avista','ALC Transportes')
	group by cli_ds_nome,dac_cd_transportadora
order by 3
select @QTDParada = (
	select count(*) from #tabela where MinutosSemEscrever > 30
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
		where MinutosSemEscrever > 30
        FOR XML PATH('') 
    ), 2 , 9999);

    SET @mensagem = 'Os clientes abaixo estão sem coletar rotas a mais de 30 minutos: '+  CHAR(10) +  CHAR(10) 
        + @coleta  +  CHAR(10) +  CHAR(10)
--select @mensagem
    RAISERROR(@mensagem, 16, 1);

END



/*
IF @QTDParada >= @QTDref
BEGIN
    DECLARE @coleta VARCHAR(1000);
    DECLARE @mensagem VARCHAR(2000) = '';
    DECLARE @texto VARCHAR(2000);
	DECLARE @msg NVARCHAR(MAX) = 'Os cleintes abaixo estao sem escrever dados de rotas a mais de 15 minutos na db_Irisys_Json.dbo.tb_ml_coleta_totalizador: ';
    

	SELECT @mensagem = @msg + COALESCE(@mensagem + CHAR(10), '') + ' ' + cli_ds_nome 
    FROM #tabela
	where MinutosSemEscrever > 10;

    RAISERROR(@mensagem , 16, 1);
END;

*/
GO
