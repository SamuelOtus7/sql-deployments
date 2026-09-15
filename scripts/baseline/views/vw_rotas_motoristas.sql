-- ============================================================
-- BASELINE: dbo.vw_rotas_motoristas
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rotas_motoristas]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- SET ANSI_NULLS ON
-- GO
-- SET QUOTED_IDENTIFIER ON
-- GO


CREATE view  [dbo].[vw_rotas_motoristas]
as

select 
	 IdTransportadora
     	,case   
            -- when  DataReferencia = '2024-07-30' and IdTransportadora = 2087146923 then 'Sim' 
            when FaixaPrimeiroUltimoPacote = 1 and usouapp = 'Sim' then 'Sim' else 'Não' end as FaixaPrimeiroUltimoPacote
	,origemsaida as Base
	,ServiceCenter
	,IdRota
	,DataReferencia as Data
	,a.NomeMotorista as Motorista
	,TipoVeiculo
	,Apuracao
	,KmColetadoAPP	 as KmApp
	,LinkMapa	 as LinkAppInterno
	,LinkMapaApp as LinkApp
	,QuantidadeApontamento 
	,case when QuantidadeApontamento  > 10 then 'Sim' else 'Não' end ColetouGps
	,UsouApp
	,UsuarioDA
	,StatusRota

	-- ,case when FaixaPrimeiroUltimoPacote = 1 then 'Sim' else 'Não' end as FaixaPrimeiroUltimoPacote
	,IdTrevo
    ,case when UsuarioDA is not null then 'Sim' else 'Não' end as PossuiUsuario
    ,UltimaRota
from tb_ml_rotas as a
left join (
select NomeMotorista,max(DataReferencia) UltimaRota
from tb_ml_rotas
where excluido = 0
and StatusRota <> 'planned'  
group BY NomeMotorista
) as b    
on a.NomeMotorista = b.NomeMotorista 

GO
