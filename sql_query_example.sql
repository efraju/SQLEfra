USE [ilion_egesticetREPSOLPERUPROY]
GO
 Object  StoredProcedure [Marketing].[uspSetCardInContactosCliExtraData]    Script Date 19032019 181221 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

=============================================    
--NAME	[Marketing].[uspSetCardInContactosCliExtraData]
--AUTOR Fred Morales 
--CREATION 14022019    
--BBDD ilion_egesticetREPSOLPERUPROY
--DESCRIPTION Procedimiento insertar las tarjetas (que existen en la tabla CONTACTOS_CLI) en la tabla CONTACTO_CLI_EXTRADATA
--PARAMETERS    
 --@PI_NCLIENTE			 número de cliente
 --@PI_LIST_NCONTACTO	 lista de números de tarjeta del cliente
=============================================

--DECLARE @V_PRUEBA [Marketing].[tNumberCard]
--INSERT INTO @V_PRUEBA VALUES ('02934ZZZ4T')
--EXEC [Marketing].[uspSetCardInContactosCliExtraData] '0293400001',@V_PRUEBA

ALTER PROCEDURE [Marketing].[uspSetCardInContactosCliExtraData]
 @PI_NCLIENTE CHAR(10),  
 @PI_LIST_NCONTACTO [Marketing].[tNumberCard] READONLY
 
AS    
 BEGIN 
	---------------------       
    -- VERSION 1.0       
    ---------------------
	SET nocount ON
	
		DECLARE @SetCard varchar(20); 
		DECLARE @RESULT int;
		DECLARE @K_NO_REQUEST varchar(10) = (SELECT CODIGO FROM ilion_egesticet..TIPOS_ENTIDADES WITH (NOLOCK) WHERE TIPO = 'ESTADO_SOL_TARJETA' AND DESCRIPCION = 'No Solicitado')
		
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity int;  
		DECLARE @ErrorState int;  

	BEGIN TRY 

		SET @SetCard = 'uspSetCardInContactosCliExtraData';
		
		BEGIN TRANSACTION @SetCard;
		
			INSERT INTO ilion_egesticet..CONTACTOS_CLI_EXTRADATA
			(NContacto,
			 NCliente,
			 CodigoRegla,
			 Estado,
			 IsQrGenerated,
			 Texto_Imprimir,
			 Terminos_Condiciones,
			 Tipo_Documento,
			 Numero_Documento,
			 Tarjeta_Fisica,
			 Estado_Solicitud				
			)
			SELECT 
			 NCONTACTO,
			 NCLIENTE,
			 NULL,
			 NULL,
			 NULL,
			 NULL,
			 NULL,
			 NULL,
			 NULL,
			 NULL,
			 @K_NO_REQUEST 
			 FROM ilion_egesticet..CONTACTOS_CLI WITH (NOLOCK)
			 WHERE NCONTACTO IN (SELECT [NCONTACTO] FROM @PI_LIST_NCONTACTO)
			 AND NCLIENTE = @PI_NCLIENTE AND CAMPO10 = '0'
			 
			 SET @RESULT = 0
		COMMIT TRANSACTION @SetCard;
		
	END TRY
	
	BEGIN CATCH  
	
		IF @@TRANCOUNT  0  ROLLBACK TRAN @SetCard  
		
			SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();  
			RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);    
		
		--SELECT -1 as RESPONSE
		SET @RESULT = -1
	
	END CATCH 
	
	SELECT @RESULT AS RESPONSE  
	
	SET NOCOUNT OFF 
	
 END
