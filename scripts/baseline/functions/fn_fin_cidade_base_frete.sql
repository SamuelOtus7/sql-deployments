-- ============================================================
-- BASELINE: dbo.fn_fin_cidade_base_frete
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_fin_cidade_base_frete]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_fin_cidade_base_frete] (
@idtransportadora int 
, @svc varchar(250)
, @tipoveiculo varchar(250)  
,@idrota varchar(50)
)
returns table
as return

select distinct bfm_nm_cidade 
from tb_fin_base_frete_motorista as a
inner join tb_dra_tipo_veiculo as b
on tvl_cd_tipo_veiculo = bfm_cd_tipo_veiculo
where bfm_cd_transportadora = @idtransportadora
and bfm_cd_service_center = @svc
and tvl_nm_tipo_veiculo = @tipoveiculo


--select distinct PAC.CIDADE

--from tb_ml_pacotes PAC
--inner join  tb_ml_rotas ROT on rot.idrota = pac.idrota and rot.idtransportadora = pac.idtransportadora


--inner join tb_dra_tipo_veiculo as veic
--on tvl_nm_tipo_veiculo = rot.TipoVeiculo
--where rot.IdTransportadora = @idtransportadora
----and rot.ServiceCenter = @svc
----and rot.TipoVeiculo = @tipoveiculo
--and rot.Excluido = 0
--and rot.StatusRota <> 'planned'
--and pac.excluido  = 0 
--AND pac.cidade is not null
--AND  pac.idrota = @idrota


GO
