-- ============================================================
-- BASELINE: dbo.UspSPE_AlarmeRotasSemEscrever
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPE_AlarmeRotasSemEscrever]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspSPE_AlarmeRotasSemEscrever]
AS
BEGIN
    
    DECLARE @dataref DATE = GETDATE();
    DECLARE @QTDref INT = 1; 
    DECLARE @QTDParada INT;
    DECLARE @mensagem VARCHAR(4000); 
    DECLARE @listaTransportadoras VARCHAR(4000);

    
    DROP TABLE IF EXISTS #TransportadorasParadas;

    
    SELECT
        cli_ds_nome,
        IdTransportadora,
        DATEDIFF(MINUTE, MAX(DataHoraInicio), GETDATE()) AS MinutosSemEscrever
    INTO #TransportadorasParadas 
    FROM tb_spe_rotas_v5 AS a WITH (ROWLOCK, READPAST, UPDLOCK)
    LEFT JOIN tb_clientes AS b
        ON a.IdTransportadora = b.cli_id_shopee 
    WHERE
        a.DataReferencia >= DATEADD(DAY, -30, GETDATE()) 
        AND b.cli_in_ativo = 1
        AND b.cli_ds_nome NOT IN ('Otus7', 'Pralog', 'Torres Transportes', 'Eco Express', 'Avista', 'ALC Transportes', 'Flashlog', 'Murici','DJM','Vite Express','Flight Cargo')
		AND b.cli_id_shopee <> 0
    GROUP BY
        b.cli_ds_nome,
        a.IdTransportadora;

    

    SELECT @QTDParada = COUNT(*)
    FROM #TransportadorasParadas
    WHERE MinutosSemEscrever > 15;

    
    IF @QTDParada >= @QTDref
    BEGIN
    
        SELECT @listaTransportadoras = STRING_AGG(
            CONCAT(cli_ds_nome, ' (', MinutosSemEscrever, ' min)'), 
            ', '
        ) WITHIN GROUP (ORDER BY MinutosSemEscrever DESC)
        FROM #TransportadorasParadas
        WHERE MinutosSemEscrever > 15;

    
        SET @mensagem = CONCAT(
            'SPE - Alarme: Estamos há mais de 15 minutos sem escrita na tb_spe_rotas_v5. ',
            @QTDParada, ' transportadora(s) afetada(s): ',
            @listaTransportadoras
        );

    
        RAISERROR(@mensagem, 16, 1);
    END
    ELSE
    BEGIN
    
        PRINT 'SPE - Rotas OK. Nenhuma transportadora está parada há mais de 15 minutos.';
    END

    
    SELECT *
    FROM #TransportadorasParadas
    WHERE MinutosSemEscrever > 15;

END
GO
