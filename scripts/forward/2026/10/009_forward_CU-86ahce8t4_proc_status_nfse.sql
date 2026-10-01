/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ahce8t4
  Autor        : Devin
  Data         : 2026-10-01
  Descrição    : Ajusta a procedure de atualização automática de status NFSe:
                 amplia #log.MotivoReprovacao para varchar(255), acompanhando
                 o tamanho das mensagens personalizadas (script 007 amplia a
                 coluna física). Mantém 'Documento fora do padrão do governo.'
                 na lista de auto-reprovação — item vigente em PROD desde
                 17/09/2026 (AuditoriaDDL AuditID 42989, login app.backend) e
                 necessário para não prender espelhos em status 'Documento
                 emitido' com NovoStatus 'Documento recusado'.
  Rollback     : scripts/rollback/2026/10/009_rollback_CU-86ahce8t4_proc_status_nfse.sql
  Objetos      : dbo.UspAtualizaStatusNFSe
  Dependências : dbo.vw_espelhos_nfse (script 008), dbo.tb_pag_espelhos,
                 dbo.tb_pag_espelhos_logs, dbo.tb_pag_espelhos_logs_nfse
  ==============================================================================*/

SET NOCOUNT ON;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[UspAtualizaStatusNFSe]
as begin

	drop table if exists #log
	create table #log
	(
		CodigoEspelho int,
		StatusAnterior int,
		StatusNovo int,
		DataHoraAlteracao datetime,
		Acao varchar(150),
		MotivoReprovacao varchar(255),
		Remetente varchar(150)
	)

	drop table if exists #ultimo
	SELECT MAX(lsm_cd_log_status) AS ultimo
	into #ultimo
			FROM tb_pag_espelhos_logs
			GROUP BY lsm_cd_motorista_nfs

	drop table if exists #logs
	SELECT DISTINCT logs.lsm_cd_motorista_nfs
	into #logs
		FROM tb_pag_espelhos_logs AS logs
		JOIN #ultimo AS ultimo
			ON logs.lsm_cd_log_status = ultimo.ultimo
		WHERE logs.lsm_cd_status_atual IN (36,37,38,39,40)
		  AND logs.lsm_cd_usuario <> 7

	IF OBJECT_ID('tempdb..#alvos_update') IS NOT NULL DROP TABLE #alvos_update;

	SELECT
		espelhos.mtn_cd_motorista_nfs
	INTO #alvos_update
	FROM tb_pag_espelhos AS espelhos
	JOIN vw_espelhos_nfse AS base
		ON espelhos.mtn_cd_motorista_nfs = base.CodigoEspelho
	LEFT JOIN #logs AS analise_manual
		ON espelhos.mtn_cd_motorista_nfs = analise_manual.lsm_cd_motorista_nfs
	WHERE (analise_manual.lsm_cd_motorista_nfs IS NULL OR base.StatusEspelho = 'Documento Emitido')
	  AND LOWER(LTRIM(RTRIM(base.StatusEspelho))) IN ('documento emitido', 'documento recusado')
	  AND base.ResultadoNFSe IN ('Nota Fiscal Integrada Via Governo','Nota fiscal validada com sucesso via IA')
	  AND base.StatusEspelho <> 'Documento aprovado'
	  AND LTRIM(RTRIM(LOWER(base.NovoStatus))) = 'documento aprovado'
	  AND espelhos.mtn_ds_link_nfs_secundario IS NULL

	UPDATE e
	SET e.mtn_cd_status = 37,
		e.mtn_dh_modificacao = GETDATE(),
		e.mtn_cd_usr_modificacao = 7
	OUTPUT
		deleted.mtn_cd_motorista_nfs      AS CodigoEspelho,
		deleted.mtn_cd_status            AS StatusAnterior,
		inserted.mtn_cd_status           AS StatusNovo,
		GETDATE()                        AS DataHoraAlteracao,
		'Aprovação automática Irisys'     AS Acao,
		NULL                             AS MotivoReprovacao,
		'Irisys'                         AS Remetente
	INTO #log
	FROM tb_pag_espelhos AS e
	JOIN #alvos_update AS a
		ON a.mtn_cd_motorista_nfs = e.mtn_cd_motorista_nfs;



	update espelhos
	set mtn_cd_status = 36,
		mtn_dh_modificacao = getdate(),
		mtn_cd_usr_modificacao = 7

	output
		deleted.mtn_cd_motorista_nfs as CodigoEspelho,
		deleted.mtn_cd_status as StatusAnterior,
		inserted.mtn_cd_status as StatusNovo,
		getdate() as DataHoraAlteracao,
		'Reprovação automática Irisys' as Acao,
		base.MotivoReprovacao as MotivoReprovacao,
		'Irisys' as Remetente

	into #log

	from tb_pag_espelhos as espelhos
		join vw_espelhos_nfse as base
		on espelhos.mtn_cd_motorista_nfs = base.CodigoEspelho
	where 1=1
		  and base.ResultadoNFSe  in (
		   'Nota Fiscal Integrada Via Governo','Nota fiscal validada com sucesso via IA'
		  ,'Nota fiscal validada com sucesso via IA'
		  ,'O arquivo PDF está sem conteúdo. Não é possível extrair a chave da NFSe automaticamente'
		  ,'Não foi possível buscar a chave da NFSe do arquivo PDF'
		  ,'O arquivo PDF é uma imagem. Não é possível extrair a chave da NFSe automaticamente'
		  ,'Não foi possível buscar a chave da NFSe do arquivo PDF'
		  ,'Documento fora do padrão do governo.'
		  )

		  and base.NovoStatus = 'Documento recusado'
		  and base.StatusEspelho in ('Documento emitido', 'Documento recusado')
		  and base.NovoStatus <> base.StatusEspelho


	insert into tb_pag_espelhos_logs_nfse
	select CodigoEspelho,
		   StatusAnterior,
		   StatusNovo,
		   DataHoraAlteracao,
		   Acao,
		   MotivoReprovacao

	from #log

	insert into tb_pag_espelhos_logs (
	lsm_cd_motorista_nfs,
	lsm_cd_status_anterior,
	lsm_cd_status_atual,
	lsm_dt_data_log,
	lsm_cd_usuario,
	lsm_ds_mensagem,
	lsm_nm_remetente
	)
	select CodigoEspelho,
		   StatusAnterior,
		   StatusNovo,
		   DataHoraAlteracao,
		   7 as Usuario,
		   Acao + isnull(':' + MotivoReprovacao,'') as Mensagem,
		   Remetente
	from #log


end
GO

PRINT 'SUCESSO: UspAtualizaStatusNFSe alterada (MotivoReprovacao varchar(255), lista de reprovação preservada).';
GO
