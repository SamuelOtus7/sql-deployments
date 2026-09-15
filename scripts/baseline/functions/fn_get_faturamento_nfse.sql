-- ============================================================
-- BASELINE: dbo.fn_get_faturamento_nfse
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_get_faturamento_nfse]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   function [dbo].[fn_get_faturamento_nfse]
(
	@data_inicio date,
	@data_fim date
)

returns table as return

--select clientes.cli_ds_nome, count(distinct enf_ds_chave_nfse) as qtde, count(*) as qtde2, sum(isnull(tentativas.qtde,1)) as tentativas
----select clientes.cli_ds_nome, count(*) as qtde
--from tb_pag_espelhos_Nfse as notas
--	join tb_pag_espelhos as espelhos on notas.enf_cd_espelho = espelhos.mtn_cd_motorista_nfs
--	join tb_clientes as clientes on espelhos.mtn_cod_cliente = clientes.cli_cd_codigo_cliente
--	left join (
--		select notas.enf_cd_espelho, count(distinct enf_ds_chave_nfse) as qtde
--		from tb_pag_espelhos_Nfse_hist as notas
--			join tb_pag_espelhos as espelhos on notas.enf_cd_espelho = espelhos.mtn_cd_motorista_nfs
--			join tb_clientes as clientes on espelhos.mtn_cod_cliente = clientes.cli_cd_codigo_cliente
--		where cast(notas.enf_dh_processamento as date) between @data_inicio and @data_fim
--			  and notas.enf_ds_resultado = 'Processado com sucesso!'
--		group by notas.enf_cd_espelho
--	) as tentativas
--	on notas.enf_cd_espelho = tentativas.enf_cd_espelho
--where cast(notas.enf_dh_processamento as date) between @data_inicio and @data_fim
--	  and clientes.cli_ds_nome <> 'Rodoprime'
--	  and notas.enf_ds_resultado = 'Processado com sucesso!'
--group by clientes.cli_ds_nome

select Cliente, count(distinct chave) as Qtde
from (
		select clientes.cli_ds_nome as Cliente,	  
			   enf_ds_chave_nfse as Chave
		from tb_pag_espelhos_Nfse as notas
			join tb_pag_espelhos as espelhos on notas.enf_cd_espelho = espelhos.mtn_cd_motorista_nfs
			join tb_clientes as clientes on espelhos.mtn_cod_cliente = clientes.cli_cd_codigo_cliente
		where cast(notas.enf_dh_processamento as date) between @data_inicio and @data_fim
			  and clientes.cli_ds_nome <> 'Rodoprime'
			  and notas.enf_ds_resultado in ('Arquivo XML - Processado com sucesso','Nota fiscal validada com sucesso via IA','Nota Fiscal Integrada Via Governo')
			  and cast(notas.enf_dh_emissao as date) between @data_inicio and @data_fim

		union

		select clientes.cli_ds_nome as Cliente,	  
			   enf_ds_chave_nfse as Chave
		from tb_pag_espelhos_Nfse as notas
			join tb_pag_espelhos as espelhos on notas.enf_cd_espelho = espelhos.mtn_cd_motorista_nfs
			join tb_clientes as clientes on espelhos.mtn_cod_cliente = clientes.cli_cd_codigo_cliente
		where cast(notas.enf_dh_processamento as date) between @data_inicio and @data_fim
			  and clientes.cli_ds_nome <> 'Rodoprime'
			  and notas.enf_ds_resultado in ('Arquivo XML - Processado com sucesso','Nota fiscal validada com sucesso via IA','Nota Fiscal Integrada Via Governo')
			  and cast(notas.enf_dh_emissao as date) between @data_inicio and @data_fim
	) as base
group by Cliente
GO
