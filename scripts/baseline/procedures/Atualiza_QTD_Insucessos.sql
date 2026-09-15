-- ============================================================
-- BASELINE: dbo.Atualiza_QTD_Insucessos
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Atualiza_QTD_Insucessos]    Script Date: 14/09/2026 12:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[Atualiza_QTD_Insucessos]
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE R
    SET R.QTDInsucessos = ISNULL(C.Qtd, 0)
    FROM TB_ML_ROTAS R
    INNER JOIN (
        -- Contagem de pacotes distintos com insucesso por rota
        SELECT 
            P.IDROTA, 
            COUNT(DISTINCT T.IDPACOTE) AS Qtd
        FROM TB_ML_PACOTES P
        INNER JOIN tb_tratativas_entregas T ON P.IDPACOTE = T.IDPACOTE and t.datacriacao = getdate()
		
        GROUP BY P.IDROTA
    ) C ON R.IDROTA = C.IDROTA;
    
END;
GO
