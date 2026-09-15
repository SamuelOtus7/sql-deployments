-- ============================================================
-- BASELINE: dbo.vw_ocupacao_frota
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_ocupacao_frota]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_ocupacao_frota] as

select 
a.codocupacao
,a.data
,a.DiaDaSemana
,a.DataCadastro
,a.idtransportadora
,a.idcliente
,a.placa
,a.tipoveiculo
,a.servicecenter
,isnull(a.DiasUteis    ,0) as DiasUteis
,isnull(a.carregamento,0) as carregamento
,isnull(a.Naocarregamento ,0) as Naocarregamento
,a.TipoFrota
,a.CategoriaVeiculo
,a.NomeMotorista
,a.tipoveiculocad
,a.DataAtualizacao
,a.codveiculo

,1 QuantidadePlaca
,b.vei_cd_ano as AnoVeiculo
,case when b.vei_in_ativo = 1 then 'Ativa' else 'Inativa' End as Status_Placa
,CASE
    WHEN vei_cd_ano >= 2004 AND vei_cd_ano <= 2009 THEN '2004-2009 (20-15 anos)'
    WHEN vei_cd_ano >= 2010 AND vei_cd_ano <= 2015 THEN '2010-2015 (14-10 anos)'
    WHEN vei_cd_ano >= 2016 THEN '2016 - Atual (Veículos mais novos)'
    ELSE 'Ano não especificado'

ENd Periodo_Lancamento

,CASE 
    WHEN YEAR(GETDATE()) - vei_cd_ano <= 15 THEN 'Dentro de 15 anos'
    ELSE 'Fora de 15 anos'
END Classificacao_Tempo
,Ciclo

from tb_ml_ocupacao_frota as a
left join tb_veiculos as b
on a.codveiculo = b.vei_cd_veiculo
where 
-- vei_in_ativo = 1 and
placa not in (
 'BVN7D70'
,'DHQ3J54'
,'GSO4482'
,'BTQ7G33'
,'DDV8G55'
,'DIU3J76'
,'BIQ1191'
,'CTQ8194'
,'DNIOC76'
)
GO
