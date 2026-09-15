-- ============================================================
-- BASELINE: dbo.usp_GetTratativaEntregas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[usp_GetTratativaEntregas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_GetTratativaEntregas] (
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

-- Tabela temporária para serviços
DROP TABLE IF EXISTS #servicos;
SELECT value AS svc INTO #servicos FROM STRING_SPLIT(@svc, ',');

-- Determina transportadora
DECLARE @transportadora INT = (
    SELECT cli_id_logistics FROM tb_clientes WITH (NOLOCK) WHERE cli_cd_codigo_cliente = @idtransportadora);

IF @marketplace = 'Shopee'
BEGIN
    SET @transportadora = (
        SELECT cli_id_shopee FROM tb_clientes WITH (NOLOCK) WHERE cli_cd_codigo_cliente = @idtransportadora);
END


-- Temp table com índice e filtro direto
DROP TABLE IF EXISTS #vw_pacotes;
WITH cte_maior_entrega AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY IdEntrega ORDER BY DataHoraEntrega DESC) AS rn
    FROM vw_pacotes WITH (NOLOCK)
    WHERE DataReferencia BETWEEN @dataInicial AND @dataFinal
      AND idtransportadora = @transportadora
      AND (
          (@StatusEntregaParametro = 'Não Entregue' AND StatusEntrega = 'Não Entregue')
          OR @StatusEntregaParametro <> 'Não Entregue')
)
SELECT IdRota, IdTransportadora, DataReferencia, IdEntrega, SubStatus,
       TipoEndereco, EnderecoParada, StatusGeralEntrega, StatusEntrega,
       DataHoraEntrega
INTO #vw_pacotes
FROM cte_maior_entrega
WHERE rn = 1;
CREATE NONCLUSTERED INDEX idx_tmp_pacotes
ON #vw_pacotes (IdTransportadora, IdRota, DataReferencia)
INCLUDE (IdEntrega, SubStatus, TipoEndereco, EnderecoParada, StatusGeralEntrega, StatusEntrega,  DataHoraEntrega);

DROP TABLE IF EXISTS #vw_rotas;
SELECT *
INTO #vw_rotas
FROM vw_rotas WITH (NOLOCK)
WHERE 
    DataReferencia BETWEEN @dataInicial AND @dataFinal
    AND idtransportadora = @transportadora;


	-- Separa os serviços entre XPT e SVC
DROP TABLE IF EXISTS #servicos_xpt, #servicos_svc;
SELECT DISTINCT UPPER(LTRIM(RTRIM(s.svc))) AS svc
INTO #servicos_xpt
FROM vw_rotas r WITH (NOLOCK)
JOIN #servicos s 
    ON UPPER(LTRIM(RTRIM(s.svc))) = UPPER(LTRIM(RTRIM(r.OrigemSaida)))
WHERE r.DataReferencia BETWEEN @dataInicial AND @dataFinal
  AND r.idtransportadora = @transportadora
  AND ISNULL(r.OrigemSaida, '') <> ISNULL(r.ServiceCenter, '');


SELECT UPPER(LTRIM(RTRIM(svc))) AS svc
INTO #servicos_svc
FROM #servicos
WHERE UPPER(LTRIM(RTRIM(svc))) NOT IN (SELECT svc FROM #servicos_xpt);

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
    motorista.mot_cnt_vl_telefone AS ContatoMotorista,
    detalhes.TelefoneComprador AS ContatoRecebedor,
    detalhes.NomeComprador AS NomeRecebedor,
    ISNULL(tratativas.MotivoTratativa, pacote.SubStatus) AS MotivoTratativa,
    tratativas.[Status],
    pacote.StatusEntrega,
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
LEFT JOIN tb_motorista AS motorista WITH (NOLOCK)
    ON rotas.NomeMotorista = motorista.mot_nm_motorista
	AND rotas.idtransportadora = @transportadora
	and @idtransportadora = mot_cd_cliente
LEFT JOIN tb_tratativas_entregas AS tratativas WITH (NOLOCK)
    ON pacote.IdTransportadora = tratativas.idtransportadora 
    AND pacote.IdRota = tratativas.idrota 
    AND pacote.IdEntrega = tratativas.idpacote
LEFT JOIN tb_ml_detalhes_pacotes AS detalhes WITH (NOLOCK)
    ON pacote.IdTransportadora = detalhes.idtransportadora 
    AND pacote.IdEntrega = detalhes.idpacote
LEFT JOIN tb_tratativas_entregas_inclusas AS inclu WITH (NOLOCK)
    ON pacote.IdEntrega = inclu.idpacote
--INNER JOIN #servicos_xpt s ON UPPER(LTRIM(RTRIM(rotas.OrigemSaida))) = s.svc
WHERE pacote.DataReferencia BETWEEN @dataInicial AND @dataFinal
  AND pacote.IdTransportadora = @transportadora
  AND (
      (@StatusEntregaParametro = 'Não Entregue' AND pacote.StatusEntrega = 'Não Entregue')
      OR (@StatusEntregaParametro <> 'Não Entregue' AND tratativas.Status = @StatusEntregaParametro)
  )
  AND rotas.Pacotesnaoentregue > 0
  AND rotas.ServiceCenter <> isnull(rotas.OrigemSaida,'0')
  AND (
      inclu.idpacote IS NOT NULL
      OR pacote.StatusGeralEntrega IN ('Insucesso')
  )
AND UPPER(LTRIM(RTRIM(
    CASE 
        WHEN rotas.ServiceCenter <> ISNULL(rotas.OrigemSaida,'')
            THEN rotas.OrigemSaida     -- XPT: filtra pelo XPT (OrigemSaida)
        ELSE rotas.ServiceCenter       -- SVC: filtra pelo ServiceCenter
    END
))) IN (
    SELECT svc FROM #servicos
)

and pacote.substatus <> 'Transferido'
  UNION ALL

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
    motorista.mot_cnt_vl_telefone AS ContatoMotorista,
    detalhes.TelefoneComprador AS ContatoRecebedor,
    detalhes.NomeComprador AS NomeRecebedor,
    ISNULL(tratativas.MotivoTratativa, pacote.SubStatus) AS MotivoTratativa,
    tratativas.[Status],
    pacote.StatusEntrega,
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
LEFT JOIN tb_motorista AS motorista WITH (NOLOCK)
    ON rotas.NomeMotorista = motorista.mot_nm_motorista
	AND rotas.idtransportadora = @transportadora
		and @idtransportadora = mot_cd_cliente

LEFT JOIN tb_tratativas_entregas AS tratativas WITH (NOLOCK)
    ON pacote.IdTransportadora = tratativas.idtransportadora 
    AND pacote.IdRota = tratativas.idrota 
    AND pacote.IdEntrega = tratativas.idpacote
LEFT JOIN tb_ml_detalhes_pacotes AS detalhes WITH (NOLOCK)
    ON pacote.IdTransportadora = detalhes.idtransportadora 
    AND pacote.IdEntrega = detalhes.idpacote
LEFT JOIN tb_tratativas_entregas_inclusas AS inclu WITH (NOLOCK)
    ON pacote.IdEntrega = inclu.idpacote
--INNER JOIN #servicos_svc s ON UPPER(LTRIM(RTRIM(rotas.ServiceCenter))) = s.svc
WHERE pacote.DataReferencia BETWEEN @dataInicial AND @dataFinal
  AND pacote.IdTransportadora = @transportadora
  AND (
      (@StatusEntregaParametro = 'Não Entregue' AND pacote.StatusEntrega = 'Não Entregue')
      OR (@StatusEntregaParametro <> 'Não Entregue' AND tratativas.Status = @StatusEntregaParametro)
  )
  AND rotas.Pacotesnaoentregue > 0
  AND rotas.ServiceCenter = isnull(rotas.OrigemSaida,'0')
  AND (
      inclu.idpacote IS NOT NULL
      OR pacote.StatusGeralEntrega IN ('Insucesso')
  )
AND UPPER(LTRIM(RTRIM(
    CASE 
        WHEN rotas.ServiceCenter <> ISNULL(rotas.OrigemSaida,'')
            THEN rotas.OrigemSaida
        ELSE rotas.ServiceCenter
    END
))) IN (
    SELECT svc FROM #servicos
)

and pacote.substatus <> 'Transferido'

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
    pacote.StatusEntrega,
    tratativas.observacao,
    tratativas.imagem,
    rotas.Paradas,
    NULL, NULL, NULL,
    NULL, NULL, NULL,
    NULL, NULL, NULL
FROM VW_PACOTES_SPE_V4 AS pacote WITH (NOLOCK)
LEFT JOIN VW_ROTAS_SPE_V4 AS rotas WITH (NOLOCK)
    ON pacote.IdTransportadora = rotas.IdTransportadora 
    AND pacote.CodigoRota = rotas.CodigoRota
LEFT JOIN tb_tratativas_entregas AS tratativas WITH (NOLOCK)
    ON pacote.IdTransportadora = tratativas.idtransportadora 
    AND pacote.CodigoRota = CAST(tratativas.idrota AS VARCHAR) 
    AND pacote.CodigoPacote = CAST(tratativas.idpacote AS VARCHAR)
INNER JOIN #servicos_xpt s ON UPPER(LTRIM(RTRIM(rotas.Hub))) = s.svc
WHERE pacote.DataReferencia BETWEEN @dataInicial AND @dataFinal
  AND pacote.IdTransportadora = @transportadora
  AND (
      (@StatusEntregaParametro = 'Não Entregue' AND pacote.StatusEntrega = 'Não Entregue')
      OR (@StatusEntregaParametro <> 'Não Entregue' AND tratativas.Status = @StatusEntregaParametro)
  )
  AND rotas.Pacotesnaoentregue > 0
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
    pacote.StatusEntrega,
    tratativas.observacao,
    tratativas.imagem,
    rotas.Paradas,
    NULL, NULL, NULL,
    NULL, NULL, NULL,
    NULL, NULL, NULL
FROM VW_PACOTES_SPE_V4 AS pacote WITH (NOLOCK)
LEFT JOIN VW_ROTAS_SPE_V4 AS rotas WITH (NOLOCK)
    ON pacote.IdTransportadora = rotas.IdTransportadora 
    AND pacote.CodigoRota = CAST(rotas.CodigoRota AS VARCHAR)
LEFT JOIN tb_tratativas_entregas AS tratativas WITH (NOLOCK)
    ON pacote.IdTransportadora = tratativas.idtransportadora 
    AND pacote.CodigoRota = CAST(tratativas.idrota AS VARCHAR) 
    AND pacote.CodigoPacote = CAST(tratativas.idpacote AS VARCHAR)
INNER JOIN #servicos_svc s ON UPPER(LTRIM(RTRIM(rotas.Hub))) = s.svc
WHERE pacote.DataReferencia BETWEEN @dataInicial AND @dataFinal
  AND pacote.IdTransportadora = @transportadora
  AND (
      (@StatusEntregaParametro = 'Não Entregue' AND pacote.StatusEntrega = 'Não Entregue')
      OR (@StatusEntregaParametro <> 'Não Entregue' AND tratativas.Status = @StatusEntregaParametro)
  )
  AND rotas.Pacotesnaoentregue > 0

union all


SELECT
    v.DataReferencia,
    CAST(v.IdRota AS VARCHAR) AS idrota,
    v.ServiceCenter,
    v.EnderecoParada AS EnderecoEntrega,
    v.DataAtualizacao AS DataHoraInsucesso,  -- aproximação; original usa DataHoraEntrega
    CAST('SSP20' AS NVARCHAR(100)) AS Base,
    v.XPT,
    v.NomeMotorista AS Motorista,
    CAST(v.IdPacote AS VARCHAR) AS idpacote,
    CAST('Residencial' AS VARCHAR(50)) AS TipoEndereco,
    CAST('AM' AS VARCHAR(2)) AS Ciclo,
    CAST('32995558965' AS VARCHAR(30)) AS ContatoMotorista,
    v.TelefoneComprador AS ContatoRecebedor,
    v.NomeComprador AS NomeRecebedor,
    ISNULL(v.MotivoTratativa, v.SubStatus) AS MotivoTratativa,
    v.StatusTratativa AS [Status],
    v.StatusEntrega,
    v.ObservacaoTratativa AS observacao,
    v.Imagem AS imagem,
    CAST(68 AS INT) AS QuantidadeParadas,
    v.NomeContato1,
    v.TelefoneContato1,
    v.EmailContato1,
    v.NomeContato2,
    v.TelefoneContato2,
    v.EmailContato2,
    v.NomeContato3,
    v.TelefoneContato3,
    v.EmailContato3
FROM dbo.vw_ml_hist_insucesso v
where idpacote in('47527429801'
,'47526119188'
,'47564379009'
)
and IdTransportadora = @idtransportadora

    OPTION (RECOMPILE);
END

GO
