-- ============================================================
-- BASELINE: dbo.usp_GetTratativaEntregas_BKUP
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[usp_GetTratativaEntregas_BKUP]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[usp_GetTratativaEntregas_BKUP] (
    @idtransportadora INT,
    @dataInicial DATE,
    @dataFinal DATE,
    @svc NVARCHAR(255),
    @marketplace NVARCHAR(255) = 'mercadolivre',
    @StatusEntregaParametro NVARCHAR(255) = 'Não Entregue'
) 
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @transportadora INT = (SELECT cli_id_logistics FROM tb_clientes WITH (NOLOCK) WHERE cli_cd_codigo_cliente = @idtransportadora);

    IF (@marketplace = 'Shopee')	
    BEGIN
        SET @transportadora = (SELECT cli_id_shopee FROM tb_clientes WITH (NOLOCK) WHERE cli_cd_codigo_cliente = @idtransportadora);
    END

    DECLARE @isXPT BIT = 0;
    
    IF EXISTS (
        SELECT 1 FROM vw_rotas WITH (NOLOCK)
        WHERE DataReferencia BETWEEN @dataInicial AND @dataFinal
        AND idtransportadora = @transportadora
        AND OrigemSaida IN (SELECT value FROM STRING_SPLIT(@svc, ','))
        AND (ServiceCenter <> OrigemSaida OR OrigemSaida IS NULL OR OrigemSaida = '')
    )
    BEGIN
        SET @isXPT = 1;
    END
    
    DROP TABLE IF EXISTS #vw_pacotes;
    SELECT * 
    INTO #vw_pacotes
    FROM vw_pacotes WITH (NOLOCK)
    WHERE DataReferencia BETWEEN @dataInicial AND @dataFinal
        AND idtransportadora = @transportadora;
    
    CREATE NONCLUSTERED INDEX [idx_tmp_pacotes]
    ON #vw_pacotes ([IdTransportadora], [IdRota], [DataReferencia])
    INCLUDE ([IdEntrega], [SubStatus], [TipoEndereco], [EnderecoParada], [StatusGeralEntrega], [DataHoraEntrega]);
    
    DROP TABLE IF EXISTS #vw_rotas;
    SELECT *
    INTO #vw_rotas
    FROM vw_rotas WITH (NOLOCK)
    WHERE DataReferencia BETWEEN @dataInicial AND @dataFinal
        AND idtransportadora = @transportadora;

    IF @isXPT = 1
    BEGIN
        -- Retornar apenas XPTs
        SELECT 
            pacote.DataReferencia,
            CAST(pacote.idrota AS VARCHAR) AS idrota,
            rotas.ServiceCenter,
            pacote.EnderecoParada AS EnderecoEntrega,
            pacote.DataHoraEntrega AS DataHoraInsucesso,
            rotas.Base,
            rotas.OrigemSaida AS XPT,
            rotas.NomeMotorista AS Motorista,
            CAST(pacote.IdEntrega AS VARCHAR) AS idpacote,
            pacote.TipoEndereco,
            CASE WHEN DATEPART(HOUR, rotas.DataHoraInicio) <= 12 THEN 'AM' ELSE 'PM' END AS Ciclo,
            motorista.Telefone AS ContatoMotorista,
            detalhes.TelefoneComprador AS ContatoRecebedor,
            detalhes.NomeComprador AS NomeRecebedor,
            ISNULL(tratativas.MotivoTratativa, pacote.SubStatus) AS MotivoTratativa,
            tratativas.[Status],
            tratativas.observacao,
            tratativas.imagem,
            rotas.QuantidadeParadas,
            detalhes.NomeContato1,
            detalhes.TelefoneContato1,
            detalhes.EmailContato1,
            detalhes.NomeContato2,
            detalhes.TelefoneContato2,
            detalhes.EmailContato2,
            detalhes.NomeContato3,
            detalhes.TelefoneContato3,
            detalhes.EmailContato3
        FROM #vw_pacotes AS pacote
        LEFT JOIN #vw_rotas AS rotas 
            ON pacote.IdTransportadora = rotas.IdTransportadora 
            AND pacote.IdRota = rotas.IdRota
        LEFT JOIN tb_ml_motoristas AS motorista WITH (NOLOCK)
            ON rotas.NomeMotorista = motorista.Nome 
            AND rotas.idtransportadora = motorista.idtransportadora
        LEFT JOIN tb_tratativas_entregas AS tratativas WITH (NOLOCK)
            ON pacote.IdTransportadora = tratativas.idtransportadora 
            AND pacote.IdRota = tratativas.idrota 
            AND pacote.identrega = tratativas.idpacote
        LEFT JOIN tb_ml_detalhes_pacotes AS detalhes WITH (NOLOCK)
            ON pacote.IdTransportadora = detalhes.idtransportadora 
            AND pacote.identrega = detalhes.idpacote
        WHERE pacote.DataReferencia BETWEEN @dataInicial AND @dataFinal
            AND pacote.IdTransportadora = @transportadora
            AND tratativas.Status = @StatusEntregaParametro
            AND rotas.Pacotesnaoentregue > 0
            AND rotas.OrigemSaida IN (SELECT value FROM STRING_SPLIT(@svc, ','))
            AND rotas.ServiceCenter <> rotas.OrigemSaida
            AND (
                pacote.IdEntrega IN (SELECT idpacote FROM tb_tratativas_entregas_inclusas WITH (NOLOCK))
                OR pacote.StatusGeralEntrega IN ('Insucesso')
            )
        
        UNION ALL
        
        SELECT 
            pacote.DataReferencia,
            pacote.CodigoRota,
            rotas.HUB,
            'N/D' AS EnderecoEntrega,
            pacote.DataHoraEntrega AS DataHoraInsucesso,
            rotas.Hub,
            rotas.Hub AS XPT,
            rotas.Motorista AS Motorista,
            pacote.CodigoPacote AS idpacote,
            'N/D' AS TipoEndereco,
            CASE WHEN DATEPART(HOUR, rotas.DataHoraInicio) <= 12 THEN 'AM' ELSE 'PM' END AS Ciclo,
            'N/D' AS ContatoMotorista,
            'N/D' AS ContatoRecebedor,
            'N/D' AS NomeRecebedor,
            ISNULL(tratativas.MotivoTratativa, pacote.SubStatus) AS MotivoTratativa,
            tratativas.[Status],
            tratativas.observacao,
            tratativas.imagem,
            rotas.Paradas,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
        FROM VW_PACOTES_SPE_V4 AS pacote WITH (NOLOCK)
        LEFT JOIN VW_ROTAS_SPE_V4 AS rotas WITH (NOLOCK)
            ON pacote.IdTransportadora = rotas.IdTransportadora 
            AND pacote.CodigoRota = rotas.CodigoRota
        LEFT JOIN tb_spe_motoristas AS motorista WITH (NOLOCK)
            ON rotas.Motorista = motorista.Nome 
            AND rotas.idtransportadora = motorista.idtransportadora
        LEFT JOIN tb_tratativas_entregas AS tratativas WITH (NOLOCK)
            ON pacote.IdTransportadora = tratativas.idtransportadora 
            AND pacote.CodigoRota = CAST(tratativas.idrota AS VARCHAR) 
            AND pacote.CodigoPacote = CAST(tratativas.idpacote AS VARCHAR)
        WHERE pacote.DataReferencia BETWEEN @dataInicial AND @dataFinal
            AND pacote.IdTransportadora = @transportadora
            AND tratativas.Status = @StatusEntregaParametro
            AND Hub = @svc
            AND rotas.Pacotesnaoentregue > 0
    END
    ELSE
    BEGIN
        -- Retornar apenas SVCs
        SELECT 
            pacote.DataReferencia,
            CAST(pacote.idrota AS VARCHAR) AS idrota,
            rotas.ServiceCenter,
            pacote.EnderecoParada AS EnderecoEntrega,
            pacote.DataHoraEntrega AS DataHoraInsucesso,
            rotas.Base,
            rotas.OrigemSaida AS XPT,
            rotas.NomeMotorista AS Motorista,
            CAST(pacote.IdEntrega AS VARCHAR) AS idpacote,
            pacote.TipoEndereco,
            CASE WHEN DATEPART(HOUR, rotas.DataHoraInicio) <= 12 THEN 'AM' ELSE 'PM' END AS Ciclo,
            motorista.Telefone AS ContatoMotorista,
            detalhes.TelefoneComprador AS ContatoRecebedor,
            detalhes.NomeComprador AS NomeRecebedor,
            ISNULL(tratativas.MotivoTratativa, pacote.SubStatus) AS MotivoTratativa,
            tratativas.[Status],
            tratativas.observacao,
            tratativas.imagem,
            rotas.QuantidadeParadas,
            detalhes.NomeContato1,
            detalhes.TelefoneContato1,
            detalhes.EmailContato1,
            detalhes.NomeContato2,
            detalhes.TelefoneContato2,
            detalhes.EmailContato2,
            detalhes.NomeContato3,
            detalhes.TelefoneContato3,
            detalhes.EmailContato3
        FROM #vw_pacotes AS pacote
        LEFT JOIN #vw_rotas AS rotas 
            ON pacote.IdTransportadora = rotas.IdTransportadora 
            AND pacote.IdRota = rotas.IdRota
        LEFT JOIN tb_ml_motoristas AS motorista WITH (NOLOCK)
            ON rotas.NomeMotorista = motorista.Nome 
            AND rotas.idtransportadora = motorista.idtransportadora
        LEFT JOIN tb_tratativas_entregas AS tratativas WITH (NOLOCK)
            ON pacote.IdTransportadora = tratativas.idtransportadora 
            AND pacote.IdRota = tratativas.idrota 
            AND pacote.identrega = tratativas.idpacote
        LEFT JOIN tb_ml_detalhes_pacotes AS detalhes WITH (NOLOCK)
            ON pacote.IdTransportadora = detalhes.idtransportadora 
            AND pacote.identrega = detalhes.idpacote
        WHERE pacote.DataReferencia BETWEEN @dataInicial AND @dataFinal
            AND pacote.IdTransportadora = @transportadora
            AND tratativas.Status = @StatusEntregaParametro
            AND rotas.Pacotesnaoentregue > 0
            AND rotas.ServiceCenter IN (SELECT value FROM STRING_SPLIT(@svc, ','))
            AND rotas.ServiceCenter = rotas.OrigemSaida
            AND (
                pacote.IdEntrega IN (SELECT idpacote FROM tb_tratativas_entregas_inclusas WITH (NOLOCK))
                OR pacote.StatusGeralEntrega IN ('Insucesso')
            )
        
        UNION ALL

        SELECT 
            pacote.DataReferencia,
            pacote.CodigoRota,
            rotas.HUB,
            'N/D' AS EnderecoEntrega,
            pacote.DataHoraEntrega AS DataHoraInsucesso,
            rotas.Hub,
            rotas.Hub AS XPT,
            rotas.Motorista AS Motorista,
            pacote.CodigoPacote AS idpacote,
            'N/D' AS TipoEndereco,
            CASE WHEN DATEPART(HOUR, rotas.DataHoraInicio) <= 12 THEN 'AM' ELSE 'PM' END AS Ciclo,
            'N/D', 'N/D', 'N/D',
            ISNULL(tratativas.MotivoTratativa, pacote.SubStatus) AS MotivoTratativa,
            tratativas.[Status],
            tratativas.observacao,
            tratativas.imagem,
            rotas.Paradas,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
        FROM VW_PACOTES_SPE_V4 AS pacote WITH (NOLOCK)
        LEFT JOIN VW_ROTAS_SPE_V4 AS rotas WITH (NOLOCK)
            ON pacote.IdTransportadora = rotas.IdTransportadora 
            AND pacote.CodigoRota = CAST(rotas.CodigoRota AS VARCHAR)
        LEFT JOIN tb_spe_motoristas AS motorista WITH (NOLOCK)
            ON rotas.Motorista = motorista.Nome 
            AND rotas.idtransportadora = motorista.idtransportadora
        LEFT JOIN tb_tratativas_entregas AS tratativas WITH (NOLOCK)
            ON pacote.IdTransportadora = tratativas.idtransportadora 
            AND pacote.CodigoRota = CAST(tratativas.idrota AS VARCHAR) 
            AND pacote.CodigoPacote = CAST(tratativas.idpacote AS VARCHAR)
        WHERE pacote.DataReferencia BETWEEN @dataInicial AND @dataFinal
            AND pacote.IdTransportadora = @transportadora
            AND tratativas.Status = @StatusEntregaParametro
            AND rotas.Pacotesnaoentregue > 0
            AND Hub = @svc
    END
END
GO
