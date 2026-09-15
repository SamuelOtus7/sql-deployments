-- ============================================================
-- BASELINE: dbo.UspPbiMonAtualizarAlertasFato
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspPbiMonAtualizarAlertasFato]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[UspPbiMonAtualizarAlertasFato]
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @dh_atualizacao DATETIME2(3) = SYSDATETIME();
    DECLARE @dt_referencia DATE = CAST(@dh_atualizacao AS DATE);
    
    UPDATE f
    SET f.dt_referencia = @dt_referencia, f.dh_atualizacao = @dh_atualizacao,
        f.id_transportadora = c.id_transportadora, f.in_cliente_ativo = c.in_cliente_ativo,
        f.in_cliente_excluido = c.in_cliente_excluido, f.in_dashboard_alarmes_habilitado = c.in_dashboard_alarmes_habilitado,
        f.in_processo_habilitado = c.in_processo_habilitado, f.in_elegivel_monitoramento = c.in_elegivel_monitoramento,
        f.nm_transportadora = c.nm_transportadora, f.plataforma = c.plataforma, f.processo_codigo = c.processo_codigo,
        f.processo_nome = c.processo_nome, f.tabela_destino = c.tabela_destino, f.tipo_regra = c.tipo_regra,
        f.sla_minutos = c.sla_minutos, f.sla_label = c.sla_label, f.nr_tolerancia_fila = c.nr_tolerancia_fila,
        f.destino_regra = c.destino_regra, f.grupo_responsavel = c.grupo_responsavel, f.etapa_falha = c.etapa_falha,
        f.motivo_falha = c.motivo_falha, f.cd_status = CAST(c.cd_status AS TINYINT), f.ds_status = c.ds_status,
        f.in_fora_janela_origem = CAST(c.in_fora_janela_origem AS BIT), f.dh_ultimo_evento_origem = c.dh_ultimo_evento_origem,
        f.dh_ultimo_evento_destino = c.dh_ultimo_evento_destino, f.qt_registros_origem = c.qt_registros_origem,
        f.qt_registros_destino = c.qt_registros_destino, f.qt_fila_pendente = c.qt_fila_pendente,
        f.qt_destino_nulos = c.qt_destino_nulos, f.nm_job = c.nm_job, f.job_ultima_execucao = c.job_ultima_execucao,
        f.job_status = c.job_status, f.proc_orquestrador = c.proc_orquestrador, f.proc_carga = c.proc_carga,
        f.ds_acao_recomendada = c.ds_acao_recomendada, f.ds_evidencia = c.ds_evidencia
    FROM dbo.tb_pbi_mon_alertas_fato AS f
    INNER JOIN dbo.vw_pbi_mon_alertas_processos_calc AS c
        ON c.cli_cd_codigo_cliente = f.cli_cd_codigo_cliente AND c.processo_id = f.processo_id;
   
   INSERT INTO dbo.tb_pbi_mon_alertas_fato (dt_referencia, dh_atualizacao, cli_cd_codigo_cliente, id_transportadora, processo_id,
        in_cliente_ativo, in_cliente_excluido, in_dashboard_alarmes_habilitado, in_processo_habilitado, in_elegivel_monitoramento,
        nm_transportadora, plataforma, processo_codigo, processo_nome, tabela_destino, tipo_regra, sla_minutos, sla_label,
        nr_tolerancia_fila, destino_regra, grupo_responsavel, etapa_falha, motivo_falha, cd_status, ds_status, in_fora_janela_origem,
        dh_ultimo_evento_origem, dh_ultimo_evento_destino, qt_registros_origem, qt_registros_destino, qt_fila_pendente, qt_destino_nulos,
        nm_job, job_ultima_execucao, job_status, proc_orquestrador, proc_carga, ds_acao_recomendada, ds_evidencia)
  
  SELECT @dt_referencia, @dh_atualizacao, c.cli_cd_codigo_cliente, c.id_transportadora, c.processo_id,
        c.in_cliente_ativo, c.in_cliente_excluido, c.in_dashboard_alarmes_habilitado, c.in_processo_habilitado, c.in_elegivel_monitoramento,
        c.nm_transportadora, c.plataforma, c.processo_codigo, c.processo_nome, c.tabela_destino, c.tipo_regra, c.sla_minutos, c.sla_label,
        c.nr_tolerancia_fila, c.destino_regra, c.grupo_responsavel, c.etapa_falha, c.motivo_falha, CAST(c.cd_status AS TINYINT), c.ds_status,
        CAST(c.in_fora_janela_origem AS BIT), c.dh_ultimo_evento_origem, c.dh_ultimo_evento_destino, c.qt_registros_origem, c.qt_registros_destino,
        c.qt_fila_pendente, c.qt_destino_nulos, c.nm_job, c.job_ultima_execucao, c.job_status, c.proc_orquestrador, c.proc_carga,
        c.ds_acao_recomendada, c.ds_evidencia
    FROM dbo.vw_pbi_mon_alertas_processos_calc AS c
    WHERE NOT EXISTS (SELECT 1 FROM dbo.tb_pbi_mon_alertas_fato AS f WHERE f.cli_cd_codigo_cliente = c.cli_cd_codigo_cliente AND f.processo_id = c.processo_id);
END;
GO
