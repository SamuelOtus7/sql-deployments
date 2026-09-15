-- ============================================================
-- BASELINE: dbo.UspReprovaMotoristasAntigos
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspReprovaMotoristasAntigos]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[UspReprovaMotoristasAntigos]

as

update aprovacoes
set mau_ds_status = 'Expirado',
	mau_ds_email = mau_ds_email + '_expirado_' + cast(mau_cd_aprovacao as varchar(10)),
	mau_in_excluido = 1
from tb_ml_aprovacao_usuario as aprovacoes
	join tb_parametros as parametros
	on aprovacoes.mau_cd_cliente = parametros.prm_cod_cliente
where parametros.prm_in_ativo = 1
	  and parametros.prm_ds_chave = 'reprovarMotorista'
	  and prm_in_excluido = 0
	  and mau_ds_status = 'Em análise'
	  and datediff(day,mau_dh_criacao, getdate()) >= prm_ds_valor

GO
