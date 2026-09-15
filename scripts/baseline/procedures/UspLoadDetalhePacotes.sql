-- ============================================================
-- BASELINE: dbo.UspLoadDetalhePacotes
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspLoadDetalhePacotes]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspLoadDetalhePacotes]
(
    @json varchar(max),
    @IdPacote bigint,
    @IdTransportadora int,
    @DataHoraColeta datetime
)
AS
BEGIN

    SELECT
        TOP 10000000
        IdPacote,
        Status,
        SubStatus,
        InicioPromessaEntrega,
        FimPromessaEntrega,
        Altura,
        Largura,
        Comprimento,
        Peso,
        Volume,
        Origem,
        NomeComprador,
        Telefone,
        Endereco,
        Rua,
        Numero,
        Latitude,
        Longitude,
        Comentario,
        TipoEndereco,
        Cidade,
        Estado,
        CAST(REPLACE(CEP, '-', '') AS int) AS CEP,
        TipoRecebedor,
        NomeRecebedor,
        SobreNomeRecebedor,
        TipoDocumento,
        Documento
    INTO #detalhes
    FROM OPENJSON(@json)
    WITH (
        IdPacote bigint '$.id',
        Status varchar(150) '$.status',
        SubStatus varchar(150) '$.substatus',
        InicioPromessaEntrega varchar(50) '$.promise_date.from',
        FimPromessaEntrega varchar(50) '$.promise_date.to',
        Altura decimal(19, 8) '$.dimensions.height',
        Largura decimal(19, 8) '$.dimensions.width',
        Comprimento decimal(19, 8) '$.dimensions.length',
        Peso decimal(19, 8) '$.dimensions.weight',
        Volume decimal(19, 8) '$.dimensions.volume',
        Origem varchar(50) '$.facility_origin_id',
        NomeComprador varchar(250) '$.receiver_info.receiver_name',
        Telefone varchar(30) '$.receiver_info.phone',
        Endereco varchar(250) '$.receiver_info.address_line',
        Rua varchar(250) '$.receiver_info.street_name',
        Numero varchar(30) '$.receiver_info.street_number',
        Latitude decimal(18, 9) '$.receiver_info.latitude',
        Longitude decimal(18, 9) '$.receiver_info.longitude',
        Comentario varchar(250) '$.receiver_info.comment',
        TipoEndereco varchar(30) '$.receiver_info.geolocation_type',
        Cidade varchar(150) '$.receiver_info.city',
        Estado varchar(30) '$.receiver_info.state',
        CEP varchar(30) '$.receiver_info.zip_code',
        TipoRecebedor varchar(50) '$.signer.relationship',
        NomeRecebedor varchar(250) '$.signer.first_name',
        SobreNomeRecebedor varchar(250) '$.signer.last_name',
        TipoDocumento varchar(50) '$.signer.identification.type',
        Documento varchar(50) '$.signer.identification.value'
    );

    SELECT
        @IdPacote AS IdPacote,
        *
    INTO #checkpoints
    FROM OPENJSON(@json, '$.checkpoints')
    WITH (
        IdCheckpoint bigint '$.id',
        NomeUsuario varchar(150) '$.user.first_name',
        SobrenomeUsuario varchar(150) '$.user.last_name',
        Status varchar(150) '$.status',
        SubStatus varchar(150) '$.substatus',
        Cluster varchar(150) '$.cluster_id',
        DataHora varchar(50) '$.date',
        Latitude decimal(19, 8) '$.location.latitude',
        Longitude decimal(19, 8) '$.location.longitude'
    );

    -- [NOVO] JSON sem linhas em #detalhes -> SEM_INFORMACAO
    IF NOT EXISTS (SELECT 1 FROM #detalhes)
    BEGIN
        MERGE dbo.tb_ml_detalhes_pacotes AS target
        USING (
            SELECT @IdPacote AS IdPacote, @IdTransportadora AS IdTransportadora
        ) AS source
            ON target.IdPacote = source.IdPacote
           AND target.IdTransportadora = source.IdTransportadora
        WHEN MATCHED THEN
            UPDATE SET
                target.SituacaoDasColetas = 'SEM_INFORMACAO',
                target.DataHoraColeta = @DataHoraColeta
        WHEN NOT MATCHED THEN
            INSERT (IdPacote, IdTransportadora, DataHoraColeta, SituacaoDasColetas)
            VALUES (@IdPacote, @IdTransportadora, @DataHoraColeta, 'SEM_INFORMACAO');
    END
    ELSE
    BEGIN
        MERGE dbo.tb_ml_detalhes_pacotes AS target
        USING #detalhes AS source
            ON target.IdPacote = source.IdPacote
           AND target.IdTransportadora = @IdTransportadora
        WHEN MATCHED THEN
            UPDATE SET
                target.Status = source.Status,
                target.SubStatus = source.SubStatus,
                target.InicioPromessaEntrega = DATEADD(SECOND, (CAST(source.InicioPromessaEntrega AS bigint)) - 10800, '1970-01-01'),
                target.FimPromessaEntrega = DATEADD(SECOND, (CAST(source.FimPromessaEntrega AS bigint)) - 10800, '1970-01-01'),
                target.Altura = source.Altura,
                target.Largura = source.Largura,
                target.Comprimento = source.Comprimento,
                target.Peso = source.Peso,
                target.Volume = source.Volume,
                target.Origem = source.Origem,
                target.NomeComprador = source.NomeComprador,
                target.TelefoneComprador = source.Telefone,
                target.Endereco = source.Endereco,
                target.Rua = source.Rua,
                target.Numero = source.Numero,
                target.Latitude = source.Latitude,
                target.Longitude = source.Longitude,
                target.Complemento = source.Comentario,
                target.TipoEndereco = source.TipoEndereco,
                target.Cidade = source.Cidade,
                target.Estado = source.Estado,
                target.CEP = source.CEP,
                target.TipoRecebedor = source.TipoRecebedor,
                target.NomeRecebedor = TRIM(source.NomeRecebedor + ' ' + source.SobreNomeRecebedor),
                target.TipoDocumento = source.TipoDocumento,
                target.Documento = source.Documento,
                target.DataHoraColeta = @DataHoraColeta,
                target.SituacaoDasColetas = 'INFORMACAO_DISPONIBILIZADA'
        WHEN NOT MATCHED THEN
            INSERT (
                IdPacote, IdTransportadora, DataHoraColeta, Status, SubStatus,
                InicioPromessaEntrega, FimPromessaEntrega, Altura, Largura, Comprimento,
                Peso, Volume, Origem, NomeComprador, TelefoneComprador, Endereco, Rua,
                Numero, Latitude, Longitude, Complemento, TipoEndereco, Cidade, Estado,
                CEP, TipoRecebedor, NomeRecebedor, TipoDocumento, Documento,
                SituacaoDasColetas
            )
            VALUES (
                source.IdPacote, @IdTransportadora, @DataHoraColeta, source.Status, source.SubStatus,
                DATEADD(SECOND, (CAST(source.InicioPromessaEntrega AS bigint)) - 10800, '1970-01-01'),
                DATEADD(SECOND, (CAST(source.FimPromessaEntrega AS bigint)) - 10800, '1970-01-01'),
                source.Altura, source.Largura, source.Comprimento, source.Peso, source.Volume,
                source.Origem, source.NomeComprador, source.Telefone, source.Endereco, source.Rua,
                source.Numero, source.Latitude, source.Longitude, source.Comentario, source.TipoEndereco,
                source.Cidade, source.Estado, source.CEP, source.TipoRecebedor,
                TRIM(source.NomeRecebedor + ' ' + source.SobreNomeRecebedor), source.TipoDocumento,
                source.Documento, 'INFORMACAO_DISPONIBILIZADA'
            );
    END;

    DROP TABLE #detalhes;
    DROP TABLE #checkpoints;

END;
GO
