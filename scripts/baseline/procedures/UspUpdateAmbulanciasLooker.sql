-- ============================================================
-- BASELINE: dbo.UspUpdateAmbulanciasLooker
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspUpdateAmbulanciasLooker]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[UspUpdateAmbulanciasLooker]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;
/**********************************************************************************************
Procedure: dbo.UspUpdateAmbulanciasLooker
Descrição:
    Esta procedure realiza o processo de atualização dos campos de ambulância nas tabelas
    de rotas '[tb_ml_rotas]', '[tb_ml_mo_rotas]' e '[tb_ml_fm_rotas]', utilizando como base
    os dados consolidados mais recentes da tabela '[tb_looker_ambulancias]'.

    O processo segue os seguintes passos:
    
    1. Para cada uma das três tabelas de rotas, realiza-se um UPDATE com base na correspondência
       entre 'DataReferencia' e 'amb_data', e entre 'IdRota' (convertido para VARCHAR) e 'amb_id_rota'.
    2. Utiliza-se uma subquery com ROW_NUMBER() para garantir que somente o registro mais recente por
       'amb_id_rota' seja considerado na atualização.
    3. Os campos atualizados em cada tabela são:
       - AmbulanciaStatus
       - AmbulanciaPagamento
       - AmbulanciaIdMotorista
    4. Todas as operações ocorrem dentro de uma transação para garantir atomicidade e integridade dos dados.
    5. Em caso de erro, é realizado um ROLLBACK da transação e a exceção é lançada com detalhes.

**********************************************************************************************/

        -- Atualiza tb_ml_rotas
        UPDATE r
        SET 
            r.AmbulanciaStatus = amb.amb_status,
            r.AmbulanciaPagamento = amb.amb_pagamento,
            r.AmbulanciaIdMotorista = amb.amb_id_motorista
        FROM [dbo].[tb_ml_rotas] r WITH (NOLOCK)
        INNER JOIN (
            SELECT 
                amb_id_rota,
                amb_data,
                amb_status,
                amb_pagamento,
                amb_id_motorista,
                amb_cd_transportadora
            FROM (
                SELECT 
                    cast(amb_id_rota as int) amb_id_rota,
                    amb_data,
                    amb_status,
                    amb_pagamento,
                    amb_id_motorista,
                    cast(amb_cd_transportadora as int) amb_cd_transportadora,
                    ROW_NUMBER() OVER (PARTITION BY amb_id_rota, amb_cd_transportadora ORDER BY amb_data DESC) AS rn
                FROM 
                    [dbo].[tb_looker_ambulancias] WITH (NOLOCK)
                where
                    amb_data >= dateadd(day,-90,cast(getdate() as date))
            ) AS sub
            WHERE sub.rn = 1
        ) AS amb
            ON r.IdRota = amb.amb_id_rota and r.IdTransportadora = amb.amb_cd_transportadora


        -- Atualiza tb_ml_mo_rotas
        UPDATE r
        SET 
            r.AmbulanciaStatus = amb.amb_status,
            r.AmbulanciaPagamento = amb.amb_pagamento,
            r.AmbulanciaIdMotorista = amb.amb_id_motorista
        FROM [dbo].[tb_ml_mo_rotas] r WITH (NOLOCK)
        INNER JOIN (
            SELECT 
                amb_id_rota,
                amb_data,
                amb_status,
                amb_pagamento,
                amb_id_motorista
            FROM (
                SELECT 
                    amb_id_rota,
                    amb_data,
                    amb_status,
                    amb_pagamento,
                    amb_id_motorista,
                    ROW_NUMBER() OVER (PARTITION BY amb_id_rota ORDER BY amb_data DESC) AS rn
                FROM [dbo].[tb_looker_ambulancias] WITH (NOLOCK)
            ) AS sub
            WHERE sub.rn = 1
        ) AS amb
            ON r.DataReferencia = amb.amb_data
            AND CAST(r.IdRota AS VARCHAR(50)) = amb.amb_id_rota;

        -- Atualiza tb_ml_fm_rotas
        UPDATE r
        SET 
            r.AmbulanciaStatus = amb.amb_status,
            r.AmbulanciaPagamento = amb.amb_pagamento,
            r.AmbulanciaIdMotorista = amb.amb_id_motorista
        FROM [dbo].[tb_ml_fm_rotas] r WITH (NOLOCK)
        INNER JOIN (
            SELECT 
                amb_id_rota,
                amb_data,
                amb_status,
                amb_pagamento,
                amb_id_motorista
            FROM (
                SELECT 
                    amb_id_rota,
                    amb_data,
                    amb_status,
                    amb_pagamento,
                    amb_id_motorista,
                    ROW_NUMBER() OVER (PARTITION BY amb_id_rota ORDER BY amb_data DESC) AS rn
                FROM [dbo].[tb_looker_ambulancias] WITH (NOLOCK)
            ) AS sub
            WHERE sub.rn = 1
        ) AS amb
            ON r.DataReferencia = amb.amb_data
            AND CAST(r.IdRota AS VARCHAR(50)) = amb.amb_id_rota;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErroMensagem NVARCHAR(4000),
                @ErroSeverity INT,
                @ErroState INT;

        SELECT
            @ErroMensagem = ERROR_MESSAGE(),
            @ErroSeverity = ERROR_SEVERITY(),
            @ErroState = ERROR_STATE();

        RAISERROR (@ErroMensagem, @ErroSeverity, @ErroState);
    END CATCH
END
GO
