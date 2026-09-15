-- ============================================================
-- BASELINE: dbo.usp_SetTratativaEntregas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[usp_SetTratativaEntregas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_SetTratativaEntregas]  (
 @idtransportadora int
,@data date 
,@svc varchar(50)
,@idrota varchar(255)
,@idpacote varchar(255)
,@MotivoTratativa varchar(150) 
,@Status varchar(150)
,@Observacao varchar(300)
,@imagem varchar(max)
,@UsuarioTratativa int = NULL
,@marketplace NVARCHAR(255) = 'mercadolivre'

) as

DECLARE @transportadora INT = (SELECT cli_id_logistics FROM tb_clientes WHERE cli_cd_codigo_cliente = @idtransportadora);
IF (@marketplace = 'Shopee')	
BEGIN
	SET @transportadora = (SELECT cli_id_shopee FROM tb_clientes WHERE cli_cd_codigo_cliente = @idtransportadora);
END

--declare @idrota int 
--, @MotivoTratativa varchar(150) 
--, @Status varchar(150)
--, @Observacao varchar(300)

delete from tb_tratativas_entregas where tb_tratativas_entregas.idpacote = @idpacote
insert into tb_tratativas_entregas 
(idtransportadora
,idrota
,idpacote
,MotivoTratativa
,Status
,Observacao
,Imagem
,DataCriacao
,DataAtualizacao
,UsuarioTratativa
)
select
	@transportadora,@idrota,@idpacote,@MotivoTratativa, @Status, @Observacao, @imagem, getdate() DataCriacao, getdate() DataAtualizacao,@UsuarioTratativa

exec usp_GetTratativaEntregas @idtransportadora,@data, @data,@svc
	
GO
