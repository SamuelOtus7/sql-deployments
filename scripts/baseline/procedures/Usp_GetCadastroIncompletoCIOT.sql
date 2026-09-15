-- ============================================================
-- BASELINE: dbo.Usp_GetCadastroIncompletoCIOT
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_GetCadastroIncompletoCIOT]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_GetCadastroIncompletoCIOT]
    @DataInicio DATE,
    @DataFim DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        b.Ano,
        b.Mes,
        b.DataReferencia,
        a.*,  
        CASE 
            WHEN b.NomeMotorista IS NULL THEN 'Nao teve rota' 
            ELSE 'Teve rota' 
        END AS TeveRota,
        b.QtdRotas,
        CASE 
            WHEN c.NomeMotorista IS NULL THEN 'Nao tem CIOT' 
            ELSE 'Tem CIOT' 
        END AS TemCIOT
    FROM vw_validaCadastroCIOT AS a
    LEFT JOIN (
        SELECT 
            NomeMotorista,
			IdMotorista,
            MONTH(DataReferencia) AS Mes,
            YEAR(DataReferencia) AS Ano,
            CASE 
                WHEN DATEPART(DAY, DataReferencia) <= 15 THEN '1 Quinzena' 
                ELSE '2 Quinzena' 
            END AS DataReferencia,
            SUM(1) AS QtdRotas  
        FROM vw_rotas   
        WHERE DataReferencia BETWEEN @DataInicio AND @DataFim
        AND IdTransportadora = 1662443209
        GROUP BY NomeMotorista,
		    IdMotorista,
            MONTH(DataReferencia),
            YEAR(DataReferencia),
            CASE 
                WHEN DATEPART(DAY, DataReferencia) <= 15 THEN '1 Quinzena' 
                ELSE '2 Quinzena' 
            END
    ) AS b
    ON a.NomeMotorista = b.NomeMotorista
    LEFT JOIN tb_trg_CIOT AS c
    ON a.NomeMotorista = c.NomeMotorista
    AND b.Mes = MONTH(c.DataHoraTermino)
	WHERE B.QtdRotas >= 1 and a.Mensagem <> '' ; -- ajuste Matheus para exibir apenas quem teve rota
END;



--select * FROM vw_validaCadastroCIOT
GO
