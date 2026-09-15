-- ============================================================
-- BASELINE: dbo.vw_dados_motoristas
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_dados_motoristas]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_dados_motoristas]
as
select
	distinct
	m.mot_cd_motorista CodigoMotorista
	,m.mot_cd_usuario CodigoUsuario
	,m.mot_cd_cliente IdCliente
    ,m.mot_nm_motorista Motorista
    ,m.mot_cpf CpfCnpj
    ,m.mot_cd_matricula Matricula
	,usu.usr_ds_email Email
	,m.mot_cnt_vl_telefone Telefone
	,m.mot_cnt_vl_celular Celular
	,m.mot_dt_nascimento DataNascimento
	,m.mot_nm_svc ServiceCenter
    ,case m.mot_cd_status
        when 1 then 'Ativo'
        when 2 then 'Inativo'
        when 3 then 'Bloqueado'
    end Status
    ,case m.mot_ctn_in_status_contrato
        when 1 then 'Ativo'
        when 0 then 'Inativo'
    end StatusContrato
	,c.ttc_nm_tipo TipoContrato
	,case m.mot_gr_cd_status
        when 1 then 'Ativo'
        when 2 then 'Inativo'
        when 3 then 'Bloqueado'
    end StatusGR
	,m.mot_gr_dt_renovacao RenovacaoGR
	,case when m.usr_in_fat_motorista_valor_app = 1 then 'Sim' else 'Não' end AcessoValorFaturamento
	,m.mot_cd_vehicle_year AnoVeiculo
	,m.mot_ds_vehicle_type TipoVeiculo
	,m.mot_ds_plate Placa
	,m.mot_emp_ds_tipo TipoEmpresa
    ,resp.mot_nm_motorista ResponsavelContrato
	,resp.mot_cpf CpfCnpjResponsavel
	--,case when resp.mot_cd_motorista is not null then ISNULL(BAN.lst_ds_valor,resp.mot_pag_nm_banco) else ISNULL(BAN.lst_ds_valor,m.mot_pag_nm_banco) end Banco
	,case when resp.mot_cd_motorista is not null then isnull(BAN2.lst_ds_valor,resp.mot_pag_nm_banco) else ISNULL(BAN.lst_ds_valor,m.mot_pag_nm_banco) end Banco
	,case when resp.mot_cd_motorista is not null then resp.mot_pag_nm_titular else m.mot_pag_nm_titular end NomeTitular
	,case when resp.mot_cd_motorista is not null then resp.mot_pag_cpf_titular else m.mot_pag_cpf_titular end CpfTitular
	,case when resp.mot_cd_motorista is not null then resp.mot_pag_cnpj_titular else m.mot_pag_cnpj_titular end CnpjTitular
	,case when resp.mot_cd_motorista is not null then resp.mot_pag_cd_agencia else m.mot_pag_cd_agencia end Agencia
	,case when resp.mot_cd_motorista is not null then resp.mot_pag_cd_conta else m.mot_pag_cd_conta end Conta
	,case when resp.mot_cd_motorista is not null then resp.mot_pag_ds_tipo_conta else m.mot_pag_ds_tipo_conta end TipoConta
	,case when resp.mot_cd_motorista is not null then isnull(TipoChavePix2.lst_ds_label,resp.mot_ds_pix_key_type) else isnull(TipoChavePix.lst_ds_label,m.mot_ds_pix_key_type) end TipoChavePix
	,case when resp.mot_cd_motorista is not null then resp.mot_ds_pix_key else m.mot_ds_pix_key end ChavePix
	,case when m.mot_cpf is null or m.mot_cpf = '' then 'Não' else 'Sim' end CpfPreenchido
	,case when case when resp.mot_cd_motorista is not null then ISNULL(BAN.lst_ds_valor,resp.mot_pag_nm_banco) else ISNULL(BAN.lst_ds_valor,m.mot_pag_nm_banco) end is null or case when resp.mot_cd_motorista is not null then ISNULL(BAN.lst_ds_valor,resp.mot_pag_nm_banco) else ISNULL(BAN.lst_ds_valor,m.mot_pag_nm_banco) end = '' then 'Não' else 'Sim' end BancoPreenchido
	,case when resp.mot_cd_motorista is not null then resp.mot_ds_empresa_cnpj else m.mot_ds_empresa_cnpj end CnpjEmpresa
	,case when resp.mot_cd_motorista is not null then resp.mot_ds_empresa_razao_social else m.mot_ds_empresa_razao_social end RazaoSocial
	,case when resp.mot_cd_motorista is not null then resp.mot_ds_empresa_nome_fantasia else m.mot_ds_empresa_nome_fantasia end NomeFantasia
	,ROW_NUMBER() over (partition by m.mot_cd_cliente, m.mot_nm_motorista order by m.mot_cd_status) as OrdemNomeMotorista
	,m.mot_pag_cd_tipo_pagamento
from
    tb_motorista m
    join tb_usuario usu on m.mot_cd_usuario = usr_cd_usuario and m.mot_cd_cliente = usu.cli_cd_codigo_cliente
	left join tb_tipo_contrato c on m.mot_ctn_cd_tipo_contrato = c.ttc_cd_tipo_contrato
    left join tb_motorista resp on resp.mot_cd_usuario = usu.usr_cd_usr_responsavel_contrato -- and m.mot_cd_usuario <> usu.usr_cd_usr_responsavel_contrato
	left join tb_lista AS BAN ON BAN.lst_cd_lista = m.mot_cd_banco AND BAN.lst_nm_lista  = 'Bancos'
	left join tb_lista AS BAN2 ON BAN2.lst_cd_lista = resp.mot_cd_banco AND BAN2.lst_nm_lista  = 'Bancos'
	left join tb_lista as TipoChavePix on m.mot_ds_pix_key_type = TipoChavePix.lst_ds_valor and TipoChavePix.lst_nm_lista  = 'Tipo Chave Pix'
	left join tb_lista as TipoChavePix2 on resp.mot_ds_pix_key_type = TipoChavePix2.lst_ds_valor and TipoChavePix2.lst_nm_lista  = 'Tipo Chave Pix'

GO
