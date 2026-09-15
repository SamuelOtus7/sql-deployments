-- ============================================================
-- BASELINE: dbo.UspAtualizaTransportadoraPacotesDiferentes
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAtualizaTransportadoraPacotesDiferentes]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[UspAtualizaTransportadoraPacotesDiferentes]
AS

--======================================================================================================
						--BKP de todos os itens que serão alterados
--======================================================================================================
	INSERT INTO tb_ml_pacotes_transportadoras_diferentes_bkp
		
		(
		
		 IdTransportadoraPacote
		,IdRotaPacote
		,IdTransportadoraRotas
		,IdRotaRotas
		,DataReferenciaPacotes
		,ServiceCenterRotas
		,DataAlteracao
		
		)
		SELECT DISTINCT 
			 a.IdTransportadora		AS IdTransportadoraPacote
			,a.IdRota				AS IdRotaPacote
			,b.IdTransportadora		AS IdTransportadoraRotas
			,b.IdRota				AS IdRotaRotas
			,a.DataReferencia		AS DataReferenciaPacotes
			,b.servicecenter		AS ServiceCenterRotas
			,CAST(GETDATE() AS DATE)AS DataAlteracao
		FROM tb_ml_pacotes a with(nolock)
	    JOIN tb_ml_rotas b	 with(nolock)
		  ON a.idrota = b.IdRota
	   WHERE a.IdTransportadora <> b.IdTransportadora
		 AND a.datareferencia >= '2025-04-01'
		 AND a.IdRota in(		------------------------------------ Pegando apenas casos que não tem mais de 1 idtransportadora por pacote
							 SELECT idrota FROM (
													SELECT count(distinct a.idtransportadora) QTD,
														   a.idrota
													FROM   tb_ml_pacotes a with(nolock)
													JOIN   tb_ml_rotas b	 with(nolock)
													  ON   a.idrota = b.IdRota		  
	    										   WHERE   a.datareferencia >= '2025-04-01'
												GROUP BY   a.IdRota
												  HAVING   count(distinct a.idtransportadora) = 1
											   )  C)
		 AND a.IdRota not in (SELECT idrotapacote FROM tb_ml_pacotes_transportadoras_diferentes_bkp)
		 AND StatusRota <>'planned'
		 AND b.excluido = 0



	DROP TABLE IF EXISTS #tb_ml_pacotes_transportadoras_diferentes
	SELECT DISTINCT 
					 a.IdTransportadora		as IdTransportadoraPacote
					,a.IdRota				as IdRotaPacote
					,b.IdTransportadora		as IdTransportadoraRotas
					,b.IdRota				as IdRotaRotas
					,a.DataReferencia		as DataReferenciaPacotes
					,b.servicecenter		as ServiceCenterRotas
					,cast(getdate() as date)as DataAlteracao
		INTO #tb_ml_pacotes_transportadoras_diferentes
		FROM tb_ml_pacotes a with(nolock)
	    JOIN tb_ml_rotas b	 with(nolock)
		  ON a.idrota = b.IdRota
	   WHERE a.IdTransportadora <> b.IdTransportadora
	     AND a.idrota = 224530328
		 AND a.datareferencia >= '2025-04-01'
		 AND a.IdRota in(		------------------------------------ Pegando apenas casos que não tem mais de 1 idtransportadora por pacote
							 SELECT idrota FROM (
													 SELECT COUNT(DISTINCT a.idtransportadora) QTD,
														    a.idrota
													   FROM tb_ml_pacotes a with(nolock)
													   JOIN tb_ml_rotas b	 with(nolock)
														 ON a.idrota = b.IdRota		  
													  WHERE a.datareferencia >= '2025-04-01'														   
												   GROUP BY a.IdRota
													 HAVING COUNT(DISTINCT a.idtransportadora) = 1
												) C)
		and StatusRota <>'planned'
		 and b.excluido = 0


--======================================================================================================
						-- UPDATE EM CASOS QUE A TRANSPORTADORA ESTÁ DIFERENTE
--======================================================================================================
   UPDATE a
      SET a.IdTransportadora = b.idtransportadora
     FROM tb_ml_pacotes a 
	 JOIN tb_ml_rotas b 
	   ON a.idrota = b.IdRota
	  AND StatusRota <>'planned'
	WHERE a.IdTransportadora <> b.IdTransportadora
	  AND a.datareferencia >= '2025-04-01'
	  AND StatusRota <>'planned'
	  AND a.IdRota  in (SELECT DISTINCT TOP 1000 idrotapacote FROM #tb_ml_pacotes_transportadoras_diferentes WHERE dataalteracao >= CAST(GETDATE()-8 AS DATE))

--==================================================================================================
--			TRATANDO PACOTES QUE TEM EM MAIS DE UMA TRANSPORTADORA COM O MESMO IDROTA
--==================================================================================================


INSERT INTO tb_ml_pacotes_transportadoras_duplicados_bkp
		
		(
		
		 IdTransportadoraPacote
		,IdRotaPacote
		,DataAlteracao
		
		)
		SELECT DISTINCT 
				  a.IdTransportadora	AS IdTransportadoraPacote
				 ,a.IdRota				AS IdRotaPacote
				 ,CAST(GETDATE() AS DATE)AS DataAlteracao
			FROM tb_ml_pacotes a with(nolock)
		    JOIN tb_ml_rotas b	 with(nolock)
			  ON a.idrota = b.IdRota
		   WHERE a.IdTransportadora <> b.IdTransportadora
		     AND a.datareferencia >= '2025-04-01'
		     AND StatusRota <>'planned'
		     AND b.excluido = 0
			 		 AND a.IdRota in(		------------------------------------ Pegando apenas casos que tem mais de 1 idtransportadora por pacote
							 SELECT idrota FROM (
													 SELECT COUNT(DISTINCT a.idtransportadora) QTD,
														    a.idrota
													   FROM tb_ml_pacotes a with(nolock)
													   JOIN tb_ml_rotas b	 with(nolock)
														 ON a.idrota = b.IdRota		  
													  WHERE a.datareferencia >= '2025-04-01'		
													    and a.excluido = 0
												   GROUP BY a.IdRota
													 HAVING COUNT(DISTINCT a.idtransportadora) > 1
												) C)
		and StatusRota <>'planned'
		 and b.excluido = 0
		 AND a.IdRota not in (SELECT idrotapacote FROM tb_ml_pacotes_transportadoras_duplicados_bkp)

	  


		DROP TABLE IF EXISTS #tb_ml_pacotes_transportadoras_duplicados
	  	SELECT DISTINCT TOP 10000
				  a.IdTransportadora	AS IdTransportadoraPacote
				 ,a.IdRota				AS IdRotaPacote
				 ,a.id					AS idpacote
				 ,b.IdTransportadora	AS IdTransportadoraRotas
				 ,CAST(GETDATE() AS DATE)AS DataAlteracao
			INTO #tb_ml_pacotes_transportadoras_duplicados
			FROM tb_ml_pacotes a with(nolock)
		    JOIN tb_ml_rotas b	 with(nolock)
			  ON a.idrota = b.IdRota
		   WHERE a.IdTransportadora <> b.IdTransportadora
		     AND a.datareferencia >= '2025-04-01'
		     AND StatusRota <>'planned'
			 		 AND a.IdRota in(		------------------------------------ Pegando apenas casos que tem mais de 1 idtransportadora por pacote
							 SELECT idrota FROM (
													 SELECT COUNT(DISTINCT a.idtransportadora) QTD,
														    a.idrota
													   FROM tb_ml_pacotes a with(nolock)
													   JOIN tb_ml_rotas b	 with(nolock)
														 ON a.idrota = b.IdRota		  
													  WHERE a.datareferencia >= '2025-04-01'		
													    and a.excluido = 0
												   GROUP BY a.IdRota
													 HAVING COUNT(DISTINCT a.idtransportadora) > 1
												) C)
		and StatusRota <>'planned'
		 and b.excluido = 0
		 and a.excluido = 0
			

   UPDATE a
      SET a.excluido = 1
     FROM tb_ml_pacotes a 
     JOIN #tb_ml_pacotes_transportadoras_duplicados b
	   ON a.idrota = b.IdRotaPacote
	  AND a.IdTransportadora = b.IdTransportadoraPacote
	  AND a.id = b.idpacote
    WHERE a.IdTransportadora <> b.IdTransportadoraRotas



GO
