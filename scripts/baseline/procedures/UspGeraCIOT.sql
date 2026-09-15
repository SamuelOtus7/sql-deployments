-- ============================================================
-- BASELINE: dbo.UspGeraCIOT
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGeraCIOT]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[UspGeraCIOT] as   
DECLARE @TodosCamposPreenchidos BIT;  
DECLARE @NomeMotorista NVARCHAR(MAX) = '';  
DECLARE @Mensagem NVARCHAR(MAX) = '';  
DECLARE @Transportadora INT = 47;  
  
-- Verifica se todos os campos obrigatórios para 'TRANSPORTADOR' estão preenchidos  
DECLARE @TabelaTransportador TABLE (mot_nm_motorista NVARCHAR(100), TodosCamposPreenchidos BIT);  
  
INSERT INTO @TabelaTransportador (mot_nm_motorista, TodosCamposPreenchidos)  
SELECT   
    mot_nm_motorista,  
    CASE   
        WHEN mot_ds_vehicle_rntrc IS NULL OR mot_ds_vehicle_rntrc = '' THEN 0  
        WHEN mot_cpf IS NULL OR mot_cpf = '' THEN 0  
        WHEN mot_cnt_vl_telefone IS NULL OR mot_cnt_vl_telefone = '' THEN 0  
        WHEN mot_cnt_vl_celular IS NULL OR mot_cnt_vl_celular = '' THEN 0  
        WHEN mot_cnt_vl_email IS NULL OR mot_cnt_vl_email = '' THEN 0  
        WHEN mot_end_nm_bairro IS NULL OR mot_end_nm_bairro = '' THEN 0  
        WHEN mot_end_ds_rua IS NULL OR mot_end_ds_rua = '' THEN 0  
        WHEN mot_end_vl_numero IS NULL THEN 0  
        WHEN mot_end_vl_cep IS NULL OR mot_end_vl_cep = '' THEN 0  
        WHEN mot_end_vl_cd_ibge IS NULL OR mot_end_vl_cd_ibge = '' THEN 0  
        WHEN mot_ds_plate IS NULL OR mot_ds_plate = '' OR LEN(mot_ds_plate) > 10 THEN 0  
  WHEN mot_cd_numero_cartao IS NULL OR mot_cd_numero_cartao = '' THEN 0  
  WHEN vei_ds_tipo_rodado IS NULL OR vei_ds_tipo_rodado ='' THEN 0  
  WHEN vei_ds_tipo_carroceria IS NULL OR vei_ds_tipo_carroceria = '' THEN 0  
        ELSE 1  
    END AS TodosCamposPreenchidos  
FROM   
    [tb_motorista] a WITH (NOLOCK)  
    join tb_veiculos b with(nolock)  
 on a.mot_ds_plate = b.vei_ds_placa  
WHERE mot_cd_cliente = @Transportadora   
AND mot_cd_status = 1;  
  
IF EXISTS (SELECT 1 FROM @TabelaTransportador WHERE TodosCamposPreenchidos = 1)  
BEGIN  
    PRINT 'Todos os campos obrigatórios para TRANSPORTADOR estão preenchidos. Atualizando status...';  
    UPDATE [tb_motorista]  
    SET mot_ds_status_integracao_transportador = '0'  
    --SELECT mot_ds_status_integracao_transportador, * FROM tb_motorista   
 WHERE mot_cd_cliente = @Transportadora   
    AND mot_cd_status = 1 and (mot_ds_status_integracao_transportador is null OR mot_ds_status_integracao_transportador = '')  
    AND mot_nm_motorista IN (SELECT mot_nm_motorista FROM @TabelaTransportador WHERE TodosCamposPreenchidos = 1);  
END  
ELSE  
BEGIN  
    SELECT mot_nm_motorista  
    FROM @TabelaTransportador  
    WHERE TodosCamposPreenchidos = 0;  
    PRINT 'Nem todos os campos obrigatórios para TRANSPORTADOR estão preenchidos. Processo interrompido.';  
    RETURN;  
END  
  
  
SET @Mensagem = '';  
  
-- Verifica se todos os campos obrigatórios para 'MOTORISTA' estão preenchidos  
DECLARE @TabelaMotorista TABLE (mot_nm_motorista NVARCHAR(100), TodosCamposPreenchidos BIT);  
  
INSERT INTO @TabelaMotorista (mot_nm_motorista, TodosCamposPreenchidos)  
SELECT   
    mot_nm_motorista,  
    CASE   
        WHEN mot_cpf IS NULL OR mot_cpf = '' THEN 0  
        WHEN mot_gr_vl_rg_motorista IS NULL OR mot_gr_vl_rg_motorista = '' THEN 0  
        WHEN mot_ds_orgao_emissor_rg IS NULL OR mot_ds_orgao_emissor_rg = '' THEN 0  
        WHEN mot_dt_nascimento IS NULL THEN 0  
        WHEN mot_gr_nm_mae IS NULL OR mot_gr_nm_mae = '' THEN 0  
        WHEN mot_gr_nm_pai IS NULL OR mot_gr_nm_pai = '' THEN 0  
        WHEN mot_cnt_vl_email IS NULL OR mot_cnt_vl_email = '' THEN 0  
        WHEN mot_cnt_vl_telefone IS NULL OR mot_cnt_vl_telefone = '' THEN 0  
        WHEN mot_cnt_vl_celular IS NULL OR mot_cnt_vl_celular = '' THEN 0  
        WHEN mot_ds_nacionalidade IS NULL OR mot_ds_nacionalidade = '' THEN 0  
        WHEN mot_end_vl_cd_ibge IS NULL OR mot_end_vl_cd_ibge = '' THEN 0  
        WHEN mot_end_nm_bairro IS NULL OR mot_end_nm_bairro = '' THEN 0  
        WHEN mot_end_ds_rua IS NULL OR mot_end_ds_rua = '' THEN 0  
        WHEN mot_end_vl_numero IS NULL THEN 0  
        WHEN mot_end_vl_cep IS NULL OR mot_end_vl_cep = '' THEN 0  
        WHEN mot_ds_plate IS NULL OR mot_ds_plate = '' OR LEN(mot_ds_plate) > 10 THEN 0  
  WHEN mot_cd_numero_cartao IS NULL OR mot_cd_numero_cartao = '' THEN 0  
  WHEN vei_ds_tipo_rodado IS NULL OR vei_ds_tipo_rodado ='' THEN 0  
  WHEN vei_ds_tipo_carroceria IS NULL OR vei_ds_tipo_carroceria = '' THEN 0  
        ELSE 1  
    END AS TodosCamposPreenchidos  
FROM   
  [tb_motorista] a WITH (NOLOCK)  
 join tb_veiculos b with(nolock)  
 on a.mot_ds_plate = b.vei_ds_placa  
WHERE mot_cd_cliente = @Transportadora   
AND mot_cd_status = 1;  
  
  
IF EXISTS (SELECT 1 FROM @TabelaMotorista WHERE TodosCamposPreenchidos = 1)  
BEGIN  
    PRINT 'Todos os campos obrigatórios para MOTORISTA estão preenchidos. Atualizando status...';  
    UPDATE [tb_motorista]  
    SET mot_ds_status_integracao_motorista = '0'  
    --SELECT mot_ds_status_integracao_motorista, * FROM tb_motorista   
 WHERE mot_cd_cliente = @Transportadora   
    AND mot_cd_status = 1 and (mot_ds_status_integracao_motorista is null or mot_ds_status_integracao_motorista = '')   
    AND mot_nm_motorista IN (SELECT mot_nm_motorista FROM @TabelaMotorista WHERE TodosCamposPreenchidos = 1);  
END  
ELSE  
BEGIN  
    SELECT mot_nm_motorista  
    FROM @TabelaMotorista  
    WHERE TodosCamposPreenchidos = 0;  
    PRINT 'Nem todos os campos obrigatórios para MOTORISTA estão preenchidos. Processo interrompido.';  
END  
  
-- VALIDA SE TEM ROTA NA QUINZENA  
  
  DECLARE @DataAtual DATE = convert(date, GETDATE());  
  DECLARE @DataInicioQuinzena DATE;  
DECLARE @DataFimQuinzena DATE;  
  
-- Define as datas de início e fim da quinzena  
IF DAY(@DataAtual) BETWEEN 1 AND 15  
BEGIN  
    SET @DataInicioQuinzena = DATEFROMPARTS(YEAR(@DataAtual), MONTH(@DataAtual), 1);  
    SET @DataFimQuinzena = CONVERT(DATE,DATEFROMPARTS(YEAR(@DataAtual), MONTH(@DataAtual), 15));  
END  
ELSE  
BEGIN  
    SET @DataInicioQuinzena = DATEFROMPARTS(YEAR(@DataAtual), MONTH(@DataAtual), 16);  
    SET @DataFimQuinzena = CONVERT(DATE, EOMONTH(@DataAtual));  
END  
  
  
IF EXISTS (  
SELECT   
    DISTINCT m.mot_nm_motorista  
 --   m.mot_cd_usuario,   
 --r.IdRota,  
 --r.DataReferencia  
      
FROM   
    tb_motorista m WITH (NOLOCK)  
INNER JOIN   
   tb_ml_rotas r WITH (NOLOCK)  
ON   
    m.mot_nm_motorista = r.NomeMotorista  
   AND m.mot_cd_usuario = r.UsuarioDA  
WHERE   
    (m.mot_ds_status_integracao_transportador = '1')  
    AND (mot_ds_status_integracao_motorista = '1')  
    AND r.DataReferencia between @DataInicioQuinzena and @DataFimQuinzena  
 AND m.mot_cd_cliente = @Transportadora  
 AND m.mot_nm_motorista IN (SELECT mot_nm_motorista FROM @TabelaMotorista WHERE TodosCamposPreenchidos = 1)  
) BEGIN  
  
-- Criar a tabela temporária antes do INSERT IF OBJECT_ID('tempdb..#CIOT_TEMP') IS NOT NULL     DROP TABLE #CIOT_TEMP;  CREATE TABLE #CIOT_TEMP (     IdCiot INT,  IdOperacaoTransporte INT,     NomeMotorista NVARCHAR(255) );  
  
 --   -- Insere um novo registro na tabela tb_trg_CIOT  
    INSERT INTO [dbo].[tb_trg_CIOT] (  
        [IdOperacaoTransporte],  
        [Instrucao],  
        [CodigoCentroDeCusto],  
        [NCM],  
        [ProprietarioCarga],  
        [PesoCarga],  
        [TipoOperacao],  
        [MunicipioOrigemCodigoIBGE],  
        [MunicipioDestinoCodigoIBGE],  
        [DataHoraInicio],  
        [DataHoraTermino],  
        [CPFCNPJContratado],  
        [ValorFrete],  
        [ValorCombustivel],  
        [ValorPedagio],  
        [ValorDespesas],  
        [ValorImpostoSestSenat],  
        [ValorImpostoIRRF],  
        [ValorImpostoINSS],  
        [ValorImpostoIcmsIssqn],  
        [ParcelaUnica],  
        [ModoCompraValePedagio],  
        [CategoriaVeiculo],  
        [NomeMotorista],  
        [CPFMotorista],  
        [RNTRCMotorista],  
        [ItemFinanceiro],  
        [IdRotaModelo],  
        [DeduzirImpostos],  
        [TarifasBancarias],  
        [QuantidadeTarifasBancarias],  
        [IdIntegrador],  
        [ValorDescontoAntecipado],  
       [CPFCNPJParticipanteDestinatario],  
        [CPFCNPJParticipanteContratante],  
        [CPFCNPJParticipanteSubcontratante],  
        [CPFCNPJParticipanteConsignatario],  
        [NumeroLacreTransporteCombustivel],  
        [ListaDestinatariosAdicionais],  
        [NumeroCartaoValePedagio],  
        [Quitacao],  
        [ValorMercadoria],  
        [PesoCarregadoMercadoria],  
        [QuantidadeCarregada],  
        [TipoCalculoAvaria],  
        [EncerraNaANTT],  
        [PorcentagemToleranciaPeso],  
        [TipoToleranciaPeso],  
        [PorcetagemPesoAMaior],  
        [DocumentoValePedagio],  
        [StatusIntegracao],  
        [DataHoraIntegracao],  
        [DataHoraModificacao],  
        [StatusProcesso],  
        [Excluido],  
        [CodCliente],  
        [CIOTRegistro],  
        [ValorImpostoPIS],  
        [ValorImpostoCofins],  
        [BaseCalculoPISCofins],  
        [ValorContratado],  
        [DadosQuitacao],  
        [TipoFormaPagamento],  
        [QuantidadeViagens],  
        [ProtocoloCIOT],  
        [ProtocoloEncerramento],  
        [IdEncerramentoOperacaoTransporte],  
        [MensagemRetorno],  
        [DataHoraFinalizacao]  
    )  
 OUTPUT INSERTED.IdCiot, INSERTED.IdOperacaoTransporte, INSERTED.NomeMotorista INTO #CIOT_TEMP (IdCiot, IdOperacaoTransporte, NomeMotorista)   
    SELECT  
        NULL AS IdOperacaoTransporte,  
        2 AS Instrucao,  
        NULL AS CodigoCentroDeCusto,  
        2 AS NCM,  
        NULL AS ProprietarioCarga,  
        300 AS PesoCarga,  
  3 TipoOperacao,   
        m.mot_end_vl_cd_ibge AS MunicipioOrigemCodigoIBGE,  
        m.mot_end_vl_cd_ibge AS MunicipioDestinoCodigoIBGE,  
        GETDATE() AS DataHoraInicio,  
        CASE WHEN DAY(GETDATE()) BETWEEN 1 AND 15 THEN DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 15) ELSE EOMONTH(GETDATE()) END DataHoraTermino,  
        CASE WHEN m.mot_cpf IS NULL THEN m.mot_ds_empresa_cnpj ELSE m.mot_cpf END AS CPFCNPJContratado,  
        '100.00' AS ValorFrete,  
        '0.00' AS ValorCombustivel,  
        '0.00' AS ValorPedagio,  
        '0.00' AS ValorDespesas,  
        '0.00' AS ValorImpostoSestSenat,  
        '0.00' AS ValorImpostoIRRF,  
        '0.00' AS ValorImpostoINSS,  
        '0.00' AS ValorImpostoIcmsIssqn,  
        0 AS ParcelaUnica,  
        4 AS ModoCompraValePedagio,  
        CASE WHEN vei_ds_tipo in ('Utilitários','Van','Outros') THEN 2 ELSE 3 END  CategoriaVeiculo, ----------Matheus  
        m.mot_nm_motorista AS NomeMotorista,  
        m.mot_cpf AS CPFMotorista,  
        m.mot_ds_vehicle_rntrc AS RNTRCMotorista,  
        NULL AS ItemFinanceiro,  
        NULL AS IdRotaModelo,  
        0 AS DeduzirImpostos,  
        '0.00' AS TarifasBancarias,  
        0 AS QuantidadeTarifasBancarias,  
        CONVERT(VARCHAR(50), CONCAT(m.mot_cd_cliente, '_', m.mot_cd_usuario, '_', FORMAT(GETDATE(), 'yyyyMMdd'))) AS IdIntegrador,  
        '0.00' AS ValorDescontoAntecipado,  
        mot_ds_empresa_cnpj AS CPFCNPJParticipanteDestinatario,  
        NULL AS CPFCNPJParticipanteContratante,  
        NULL AS CPFCNPJParticipanteSubcontratante,  
        NULL AS CPFCNPJParticipanteConsignatario,  
        NULL AS NumeroLacreTransporteCombustivel,  
        NULL AS ListaDestinatariosAdicionais,  
        NULL AS NumeroCartaoValePedagio,  
        0 AS Quitacao,  
        '100.00' AS ValorMercadoria,  
        '300.00' AS PesoCarregadoMercadoria,  
        1 AS QuantidadeCarregada,  
        NULL AS TipoCalculoAvaria,  
        0 AS EncerraNaANTT,  
        '5.00' AS PorcentagemToleranciaPeso,  
        1 AS TipoToleranciaPeso,  
        '2.00' AS PorcetagemPesoAMaior,  
        NULL AS DocumentoValePedagio,  
        0 AS StatusIntegracao,  
        NULL AS DataHoraIntegracao,  
        NULL AS DataHoraModificacao,  
        0 AS StatusProcesso,  
        0 AS Excluido,  
        mot_cd_cliente AS CodCliente,  
        NULL AS CIOTRegistro,  
        '0.00' AS ValorImpostoPIS,  
        '0.00' AS ValorImpostoCofins,  
        '0.00' AS BaseCalculoPISCofins,  
        NULL AS ValorContratado,  
        NULL AS DadosQuitacao,  
        3 AS TipoFormaPagamento,  
        1 AS QuantidadeViagens,  
        NULL AS ProtocoloCIOT,  
        NULL AS ProtocoloEncerramento,  
        NULL AS IdEncerramentoOperacaoTransporte,  
        NULL AS MensagemRetorno,  
        NULL AS DataHoraFinalizacao  
    FROM tb_motorista m  
 LEFT JOIN [tb_trg_CIOT] ciot WITH (NOLOCK)     ON ciot.NomeMotorista = m.mot_nm_motorista and CONVERT(DATE, ciot.DataHoraTermino) = @DataFimQuinzena  
 LEFT JOIN tb_veiculos b  
 on m.mot_ds_plate = b.vei_ds_placa  
    WHERE  
        (m.mot_ds_status_integracao_transportador = '1')  
        AND (m.mot_ds_status_integracao_motorista = '1')  
        AND m.mot_cd_cliente = 47  
  AND m.mot_nm_motorista IN (SELECT mot_nm_motorista FROM @TabelaMotorista WHERE TodosCamposPreenchidos = 1)  
  AND ciot.NomeMotorista IS NULL;  
  
  END  
  
  ELSE PRINT 'FIM'  
    
IF EXISTS (SELECT 1 FROM #CIOT_TEMP) BEGIN  
    -- Insere parcelas apenas se houver CIOTs inseridos  
    INSERT INTO [tb_trg_CIOTParcelas] (  
        IdCiot,  
        IdOperacaoTransporte,  
        DescricaoParcela,  
        Valor,  
        NumeroParcela,  
        DataVencimento,  
        TipoDaParcela,  
        FormaPagamento,  
        CartaoPagamento,  
        CodigoBanco,  
        AgenciaDeposito,  
        ContaDeposito,  
        DigitoContaDeposito,  
        ProcessarAutomaticamente,  
        FlagContaPoupanca,  
        VariacaoContaPoupanca,  
        ItemFinanceiroParcela,  
        IdOperacaoTransporteParcela,  
        Mensagem  
    )  
    SELECT    
        c.IdCiot,  
        c.IdOperacaoTransporte,  
        'Total' AS DescricaoParcela,  
        100 AS Valor,  
        1 AS NumeroParcela,  
        CASE   
            WHEN DAY(GETDATE()) BETWEEN 1 AND 15 THEN DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 15)  
            ELSE EOMONTH(GETDATE())  
        END AS DataVencimento,  
        3 AS TipoDaParcela,  
        1 AS FormaPagamento,  
        m.mot_cd_numero_cartao AS CartaoPagamento,  
        NULL AS CodigoBanco,  
        NULL AS AgenciaDeposito,  
        NULL AS ContaDeposito,  
        NULL AS DigitoContaDeposito,  
        0 AS ProcessarAutomaticamente,  
        0 AS FlagContaPoupanca,  
        NULL AS VariacaoContaPoupanca,  
        NULL AS ItemFinanceiroParcela,  
        NULL AS IdOperacaoTransporteParcela,  
        NULL AS Mensagem  
    FROM [tb_trg_CIOT] c INNER JOIN [tb_motorista] m      ON m.mot_nm_motorista = c.NomeMotorista LEFT JOIN [tb_trg_CIOTParcelas] p      ON c.IdCiot = p.IdCiot -- Evita duplicação na tabela Parcelas WHERE      p.IdCiot IS NULL -- Somente registros que ainda não foram inseridos     AND m.mot_ds_status_integracao_transportador = '1'     AND m.mot_ds_status_integracao_motorista = '1'     AND m.mot_cd_cliente = @Transportadora;  
END  
  
IF EXISTS (SELECT 1 FROM #CIOT_TEMP) BEGIN     INSERT INTO [tb_trg_CIOTVeiculos] (         Placa, IdCiot, IdOperacaoTransporte, RNTRC     )     SELECT       m.mot_ds_plate AS Placa,     c.IdCiot,     c.IdOperacaoTransporte,     m
.mot_ds_vehicle_rntrc AS RNTRC FROM [tb_trg_CIOT] c INNER JOIN [tb_motorista] m      ON m.mot_nm_motorista = c.NomeMotorista LEFT JOIN [tb_trg_CIOTVeiculos] v      ON c.IdCiot =
 v.IdCiot -- Evita duplicação na tabela Veículos WHERE      v.IdCiot IS NULL -- Somente registros que ainda não foram inseridos     AND m.mot_ds_status_integracao_transportador = '1'     AND m.mot_ds_status_integracao_motorista = '1'  AND LEN(mot_ds_plate) <= 10     AND m.mot_cd_cliente = @Transportadora;  
 END  
GO
