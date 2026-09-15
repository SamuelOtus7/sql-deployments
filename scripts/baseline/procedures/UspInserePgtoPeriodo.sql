-- ============================================================
-- BASELINE: dbo.UspInserePgtoPeriodo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspInserePgtoPeriodo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspInserePgtoPeriodo](@DataParametro DATE)

AS

BEGIN

DECLARE @Ano INT,
		@Mes INT,
		@Dia INT,
		@Data DATE,
		@NomeMes VARCHAR(100),
		@AnoMes VARCHAR(6)

IF(@DataParametro IS NULL)
BEGIN
	SET @Data = GETDATE()
END
ELSE
BEGIN
	SET @Data = @DataParametro
END

SET @Dia = DAY(@Data)

IF(@DataParametro IS NOT NULL OR @Dia = 26 OR @Dia = 11)
BEGIN
	IF(@Data BETWEEN CONVERT(DATE,CONVERT(VARCHAR(6),@Data,112) + '26') AND CONVERT(DATE,CONVERT(VARCHAR(6),DATEADD(MONTH,1,@Data),112) + '10'))
	BEGIN
		SET @Ano = YEAR(DATEADD(MONTH,1,@Data))
		SET @Mes = MONTH(DATEADD(MONTH,1,@Data))
		SET @AnoMes = CONVERT(VARCHAR(6),DATEADD(MONTH,1,@Data),112)
	END
	ELSE
	BEGIN
		SET @Ano = YEAR(@Data)
		SET @Mes = MONTH(@Data)
		SET @AnoMes = CONVERT(VARCHAR(6),@Data,112)
	END

	SET @NomeMes = CASE
					   WHEN @Mes = 1
						   THEN 'Janeiro'
					   WHEN @Mes = 2
						   THEN 'Fevereiro'
					   WHEN @Mes = 3
						   THEN 'Março'
					   WHEN @Mes = 4
						   THEN 'Abril'
					   WHEN @Mes = 5
						   THEN 'Maio'
					   WHEN @Mes = 6
						   THEN 'Junho'
					   WHEN @Mes = 7
						   THEN 'Julho'
					   WHEN @Mes = 8
						   THEN 'Agosto'
					   WHEN @Mes = 9
						   THEN 'Setembro'
					   WHEN @Mes = 10
						   THEN 'Outubro'
					   WHEN @Mes = 11
						   THEN 'Novembro'
					   WHEN @Mes = 12
						   THEN 'Dezembro'
					   ELSE ''
				   END

	DROP TABLE IF EXISTS #PERIODO_INSERT

	CREATE TABLE #PERIODO_INSERT(
		pgp_nm_periodo VARCHAR(50),
		pgp_dt_inicio DATE,
		pgp_dt_fim DATE,
		pgp_cd_status INT,
		pgp_dh_criacao DATETIME,
		pgp_cd_usr_criacao INT,
		pgp_dh_modificacao DATETIME,
		pgp_cd_usr_modificacao INT,
		pgp_cd_cliente INT,
		pgp_in_ativo BIT,
		pgp_in_excluido BIT,
		pgp_cd_tipo_contratos VARCHAR(200),
		pgp_cd_cliente_transportadora INT,
		pgp_dt_pagamento DATE,
		pgp_dt_limite_reanalise DATE
	)

	INSERT INTO #PERIODO_INSERT(
		pgp_nm_periodo,
		pgp_dt_inicio,
		pgp_dt_fim,
		pgp_cd_status,
		pgp_dh_criacao,
		pgp_cd_usr_criacao,
		pgp_dh_modificacao,
		pgp_cd_usr_modificacao,
		pgp_cd_cliente,
		pgp_in_ativo,
		pgp_in_excluido,
		pgp_cd_tipo_contratos,
		pgp_cd_cliente_transportadora,
		pgp_dt_pagamento,
		pgp_dt_limite_reanalise
	)

	SELECT	CASE
				WHEN @Dia < 26
					THEN
						CASE
							WHEN @Data BETWEEN CONVERT(DATE,CONVERT(VARCHAR(6),DATEADD(MONTH,-1,@Data),112) + '26') AND CONVERT(DATE,CONVERT(VARCHAR(6),@Data,112) + '10')
								THEN 'Q1' + ' ' + @NomeMes + ' ' + CONVERT(VARCHAR,@Ano)
							ELSE 'Q2' + ' ' + @NomeMes + ' ' + CONVERT(VARCHAR,@Ano)
						END
				ELSE
					CASE
						WHEN @Data BETWEEN CONVERT(DATE,CONVERT(VARCHAR(6),@Data,112) + '26') AND CONVERT(DATE,CONVERT(VARCHAR(6),DATEADD(MONTH,1,@Data),112) + '10')
							THEN 'Q1' + ' ' + @NomeMes + ' ' + CONVERT(VARCHAR,@Ano)
						ELSE 'Q2' + ' ' + @NomeMes + ' ' + CONVERT(VARCHAR,@Ano)
					END
			END				AS pgp_nm_periodo,
			CASE
				WHEN @Dia < 26
					THEN
						CASE
							WHEN @Data BETWEEN CONVERT(DATE,CONVERT(VARCHAR(6),DATEADD(MONTH,-1,@Data),112) + '26') AND CONVERT(DATE,CONVERT(VARCHAR(6),@Data,112) + '10')
								THEN DATEADD(MONTH,-1,CONVERT(DATE,@AnoMes + '26'))
							ELSE CONVERT(DATE,@AnoMes + '11')
						END
				ELSE
					CASE
						WHEN @Data BETWEEN CONVERT(DATE,CONVERT(VARCHAR(6),@Data,112) + '26') AND CONVERT(DATE,CONVERT(VARCHAR(6),DATEADD(MONTH,1,@Data),112) + '10')
							THEN DATEADD(MONTH,-1,CONVERT(DATE,@AnoMes + '26'))
						ELSE CONVERT(DATE,@AnoMes + '11')
					END
			END				AS pgp_dt_inicio,
			CASE
				WHEN @Dia < 26
					THEN
						CASE
							WHEN @Data BETWEEN CONVERT(DATE,CONVERT(VARCHAR(6),DATEADD(MONTH,-1,@Data),112) + '26') AND CONVERT(DATE,CONVERT(VARCHAR(6),@Data,112) + '10')
								THEN CONVERT(DATE,@AnoMes + '10')
							ELSE CONVERT(DATE,@AnoMes + '25')
						END
				ELSE
					CASE
						WHEN @Data BETWEEN CONVERT(DATE,CONVERT(VARCHAR(6),@Data,112) + '26') AND CONVERT(DATE,CONVERT(VARCHAR(6),DATEADD(MONTH,1,@Data),112) + '10')
							THEN CONVERT(DATE,@AnoMes + '10')
						ELSE CONVERT(DATE,@AnoMes + '25')
					END
			END				AS pgp_dt_fim,
			1				AS pgp_cd_status,
			GETDATE()		AS pgp_dh_criacao,
			4030			AS pgp_cd_usr_criacao,
			GETDATE()		AS pgp_dh_modificacao,
			4030			AS pgp_cd_usr_modificacao,
			45				AS pgp_cd_cliente,
			1				AS pgp_in_ativo,
			0				AS pgp_in_excluido,
			-1				AS pgp_cd_tipo_contratos,
			333				AS pgp_cd_cliente_transportadora,
			NULL			AS pgp_dt_pagamento,
			NULL			AS pgp_dt_limite_reanalise


	INSERT INTO tb_pgto_periodo(
		pgp_nm_periodo,
		pgp_dt_inicio,
		pgp_dt_fim,
		pgp_cd_status,
		pgp_dh_criacao,
		pgp_cd_usr_criacao,
		pgp_dh_modificacao,
		pgp_cd_usr_modificacao,
		pgp_cd_cliente,
		pgp_in_ativo,
		pgp_in_excluido,
		pgp_cd_tipo_contratos,
		pgp_cd_cliente_transportadora,
		pgp_dt_pagamento,
		pgp_dt_limite_reanalise
	)

	SELECT 	pgp_nm_periodo,
			pgp_dt_inicio,
			pgp_dt_fim,
			pgp_cd_status,
			pgp_dh_criacao,
			pgp_cd_usr_criacao,
			pgp_dh_modificacao,
			pgp_cd_usr_modificacao,
			pgp_cd_cliente,
			pgp_in_ativo,
			pgp_in_excluido,
			pgp_cd_tipo_contratos,
			pgp_cd_cliente_transportadora,
			pgp_dt_pagamento,
			pgp_dt_limite_reanalise
	FROM #PERIODO_INSERT AS INS
	WHERE NOT EXISTS (
						SELECT 1
						FROM tb_pgto_periodo
						WHERE pgp_cd_cliente  = INS.pgp_cd_cliente
							AND pgp_dt_inicio = INS.pgp_dt_inicio
							AND pgp_dt_fim	  = INS.pgp_dt_fim
					  )

	IF @@IDENTITY IS NOT NULL
	BEGIN
		EXEC UspDetalhePagamento @@IDENTITY
	END
END

ELSE
BEGIN
	RETURN
END

END
GO
