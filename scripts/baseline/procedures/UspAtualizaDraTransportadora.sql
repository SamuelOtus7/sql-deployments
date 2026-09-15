-- ============================================================
-- BASELINE: dbo.UspAtualizaDraTransportadora
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAtualizaDraTransportadora]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[UspAtualizaDraTransportadora]
as
insert into tb_dra_transportadora
select target.*
from (
		select cli_id_logistics as tpr_cd_transportadora,
			   cli_ds_nome as tpr_nome_transportadora,
			   cast(1 as tinyint) as tpr_cd_marketplace
		from tb_clientes
		where cli_id_logistics > 0
			  and cli_in_ativo = 1

		union all

		select cli_id_shopee as tpr_cd_transportadora,
			   cli_ds_nome as tpr_nome_transportadora,
			   cast(2 as tinyint) as tpr_cd_marketplace
		from tb_clientes
		where cli_id_shopee > 0
			  and cli_in_ativo = 1
	) as target
		left join tb_dra_transportadora as source
		on target.tpr_cd_transportadora = source.tpr_cd_transportadora
		and target.tpr_cd_marketplace = source.tpr_cd_marketplace
where source.tpr_cd_transportadora is null
GO
