-- ============================================================
-- BASELINE: dbo.vw_dados_motoristas_spe
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_dados_motoristas_spe]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_dados_motoristas_spe] as    
   
select    
    a.IdMotorista   
    ,b.cli_cd_codigo_cliente as IdTransportadora  
    ,usr_cd_usuario  as idDA 
    ,isnull(mot_cpf, RIGHT(REPLICATE('0', 11) + c.CPF, 11)) CPF 
    ,NomeMotorista   
    ,case when usr_in_ativo = 1 then 'Ativo' else 'Inativo' end Ativo   
    ,isnull(mot_cnt_vl_email,Email) Email   
    ,NULL Telefone   
    ,NULL IdSite   
    ,StatusLogin 
    ,Renavam 
    ,ModificacaoSPX 
    ,DisplayStatus 
    ,Aniversario 
    ,NomeStation 
    ,UltimoLoginSPX 
    ,Cidade 
    ,Rua 
    ,Numero 
    ,Cep 
    ,FlagAgencia   
  
 
from [dbo].[tb_spe_motoristas] as a  with(nolock) 
 
join [dbo].[tb_usuario] as usu with(nolock) 
on usu.usr_nm_usuario = a.nomemotorista 
 
inner join tb_clientes as b   
on cli_in_ativo = 1 
and usu.cli_cd_codigo_cliente = b.cli_cd_codigo_cliente 
and a.IdTransportadora = b.cli_id_shopee
 
left join tb_spe_cpf_paleativo as c 
on a.idmotorista = c.IdMotorista 
 
left join tb_motorista as mot 
on a.Nome = mot_nm_motorista 
and mot_cd_cliente = b.cli_cd_codigo_cliente 
 

 where a.IdTransportadora > 0
 --and  a.IdMotorista   = 83201


GO
