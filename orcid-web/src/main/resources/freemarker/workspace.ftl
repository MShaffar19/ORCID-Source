<#--

    =============================================================================

    ORCID (R) Open Source
    http://orcid.org

    Copyright (c) 2012-2013 ORCID, Inc.
    Licensed under an MIT-Style License (MIT)
    http://orcid.org/open-source-license

    This copyright and license information (including a link to the full license)
    shall be included in its entirety in all copies or substantial portion of
    the software.

    =============================================================================

-->
<#-- @ftlvariable name="profile" type="org.orcid.jaxb.model.message.OrcidProfile" -->
<@protected nav="record">
<#escape x as x?html>
<#if emailVerified?? && emailVerified>
    <div class="alert alert-success">
        <strong><@spring.message "orcid.frontend.web.email_verified"/></strong>
    </div>
</#if>

<#if invalidVerifyUrl?? && invalidVerifyUrl>
    <div class="alert alert-success">
        <strong><@spring.message "orcid.frontend.web.invalid_verify_link"/></strong>
    </div>
</#if>


<#if invalidOrcid?? && invalidOrcid>
    <div class="alert alert-success">
        <strong><@spring.message "orcid.frontend.web.invalid_switch_orcid"/></strong>
    </div>
</#if>

<div class="row workspace-top public-profile">

	<#-- hidden divs that trigger angular -->
	<#if RequestParameters['recordClaimed']??>
	    <div ng-controller="ClaimThanks" style="display: hidden;"></div>	    
	<#elseif !Session.CHECK_EMAIL_VALIDATED?exists && !inDelegationMode>
    	<div ng-controller="VerifyEmailCtrl" style="display: hidden;"></div>
	</#if>

    <div class="col-md-3 lhs left-aside">
    	<div class="workspace-profile">
            <#include "includes/id_banner.ftl"/>
	        <#if ((profile.orcidBio.personalDetails.otherNames.otherName)?size != 0)>
	        	<p><strong><@orcid.msg 'workspace.Alsoknownas'/></strong><br />
		       		<#list profile.orcidBio.personalDetails.otherNames.otherName as otherName>
		       			${otherName.content}<#if otherName_has_next><br /></#if>
		       		</#list>
		       	</p>
	       	</#if>
            <#if (countryName)??>
                <p><strong><@orcid.msg 'public_profile.labelCountry'/></strong>
                ${(countryName)!}
                </p>
            </#if>
	       	<#if (profile.orcidBio.keywords)?? && (profile.orcidBio.keywords.keyword?size != 0)>
	        	<p><strong><@orcid.msg 'public_profile.labelKeywords'/></strong> 
		       		<#list profile.orcidBio.keywords.keyword as keyword>
		       			${keyword.content}<#if keyword_has_next>,</#if>
		       		</#list></p>
	       	</#if>
	       	<#if (profile.orcidBio.researcherUrls)?? && (profile.orcidBio.researcherUrls.researcherUrl?size != 0)>
	        	<p><strong><@orcid.msg 'public_profile.labelWebsites'/></strong> <br/>
		       		<#list profile.orcidBio.researcherUrls.researcherUrl as url>
		       		   <a href="<@orcid.absUrl url.url/>" target="_blank" rel="nofollow"><#if (url.urlName.content)! != "">${url.urlName.content}<#else>${url.url.value}</#if></a><#if url_has_next><br/></#if>
		       		</#list></p>
	       	</#if>
       		<div ng-controller="ExternalIdentifierCtrl" ng-hide="!externalIdentifiersPojo.externalIdentifiers.length" ng-cloak>	       			
       			<p><strong><@orcid.msg 'public_profile.labelOtherIDs'/></strong></p>
       			<div ng-repeat='externalIdentifier in externalIdentifiersPojo.externalIdentifiers'>
		        	<span ng-hide="externalIdentifier.externalIdUrl">{{externalIdentifier.externalIdCommonName.content}} {{externalIdentifier.externalIdReference.content}}</span>
		        	<span ng-show="externalIdentifier.externalIdUrl"><a href="{{externalIdentifier.externalIdUrl.value}}" target="_blank">{{externalIdentifier.externalIdCommonName.content}} {{externalIdentifier.externalIdReference.content}}</a></span>
			   		<a ng-click="deleteExternalIdentifier($index)" class="glyphicon glyphicon-trash grey"></a>       			
       			</div>
			</div>     
	       	<a href="<@spring.url '/account/manage-bio-settings'/>" id="update-personal-modal-link" class="label btn-primary"><@orcid.msg 'workspace.Update'/></a>
        </div>
    </div>
    <div class="col-md-9 right-aside">
        <div class="workspace-right">
        	<div class="workspace-inner workspace-header" ng-controller="WorkspaceSummaryCtrl">
                <div class="alert alert-info" ng-show="showAddAlert()" ng-cloak><strong><@orcid.msg 'workspace.addinformationaboutyou'/></strong></div>
                <!-- Summary 
        		<div class="row">
        			
        			
	        		<div class="workspace-overview col-md-3 col-sm-3 col-xs-6" id="works-overview">
	        			<a href="#workspace-publications" class="overview-count" ng-click="workspaceSrvc.openWorks()"><span ng-bind="worksSrvc.works.length"></span></a>
	        			<a href="#workspace-publications" class="overview-title" ng-click="workspaceSrvc.openWorks()"><@orcid.msg 'workspace.Works'/></a>
	                    <br />	                    	
	                    <a href="#workspace-publications" class="btn-update no-icon" ng-click="workspaceSrvc.openWorks()"><@orcid.msg 'workspace.view'/></a>	                    
	        		</div>
		            <div class="workspace-overview col-md-3 col-sm-3 col-xs-6" id="educations-overview">
		                <a href="#workspace-educations" class="overview-count" ng-click="workspaceSrvc.openEducation()"><span ng-bind="affiliationsSrvc.educations.length"></span></a>
		                <a href="#workspace-educations" class="overview-title" ng-click="workspaceSrvc.openEducation()"><@orcid.msg 'org.orcid.jaxb.model.message.AffiliationType.education'/></a>
		                <br />
		                <a href="#workspace-educations" class="btn-update no-icon" ng-click="workspaceSrvc.openEducation()"><@orcid.msg 'workspace.view'/></a>
		            </div>
		            <div class="workspace-overview col-md-3 col-sm-3 col-xs-6" id="employments-overview">
		                <a href="#workspace-employments" class="overview-count" ng-click="workspaceSrvc.openEmployment()"><span ng-bind="affiliationsSrvc.employments.length"></span></a>
		                <a href="#workspace-employments" class="overview-title" ng-click="workspaceSrvc.openEmployment()"><@orcid.msg 'org.orcid.jaxb.model.message.AffiliationType.employment'/></a>
		                <br />
		                <a href="#workspace-employments" class="btn-update no-icon" ng-click="workspaceSrvc.openEmployment()"><@orcid.msg 'workspace.view'/></a>
		             </div>
					<div class="workspace-overview col-md-3 col-sm-3 col-xs-6">
        				<a href="#workspace-fundings" class="overview-count" ng-click="workspaceSrvc.openFunding()"><span ng-bind="fundingSrvc.fundings.length"></span></a>
        				<a href="#workspace-fundings" class="overview-title" ng-click="workspaceSrvc.openFunding()"><@orcid.msg 'workspace.Funding'/></a>
        				<br />
        				<a href="#workspace-employments" class="btn-update no-icon" ng-click="workspaceSrvc.openFunding()"><@orcid.msg 'workspace.view'/></a>
        			</div>
	        	</div>
	        	 -->
	        	 <!-- Personal information will be here now -->
	        	 
	        	 
        	</div>
        	<div class="workspace-accordion" id="workspace-accordion">        		
        		<!-- Personal Information -->
            	<div id="workspace-personal" class="workspace-accordion-item workspace-accordion-active" ng-controller="PersonalInfoCtrl">
        			<div class="workspace-accordion-header">
        				<div class="row">
        					<div class="col-md-6 col-sm-6 col-xs-12">
		 			   			<a href="" ng-click="toggleDisplayInfo($event)" class="toggle-text">
		  			   				<i class="glyphicon-chevron-down glyphicon x0" ng-class="{'glyphicon-chevron-right':displayInfo==false}"></i>  			   			
		 			   				<@orcid.msg 'workspace.personal_information'/>
		 			   			</a>
	 			   			</div>
	 			   			<div class="col-md-6 col-sm-6 col-xs-12" ng-show="displayInfo">
		   			   			<a href="<@spring.url '/account/manage-bio-settings'/>" id="update-personal-modal-link" class="action-option manage-button">
		   			   				<span class="glyphicon glyphicon-pencil"></span><@orcid.msg 'workspace.Update'/>
		   			   			</a>
		   			   		</div>
   			   			</div>
        			</div>
            		<div class="workspace-accordion-content" ng-show="displayInfo">
            			<#include "workspace_personal.ftl"/>
        			</div>
            	</div>
            	<!-- Affiliations -->
                <#include "workspace_affiliations_body_list.ftl"/>
                <!-- Fundings -->
               	<#include "workspace_fundings_body_list.ftl"/>
		        <!-- Works -->                
                <div id="workspace-publications" class="workspace-accordion-item workspace-accordion-active" ng-controller="WorkCtrl">
                	<div class="workspace-accordion-header">
                		<div class="row">
                			<div class="col-md-3 col-sm-3 col-xs-12">
		                		<div class="work-title" ng-controller="WorkspaceSummaryCtrl">
			                		<a href="" ng-click="workspaceSrvc.toggleWorks()" class="toggle-text">
				       			       <i class="glyphicon-chevron-down glyphicon x0" ng-class="{'glyphicon-chevron-right':workspaceSrvc.displayWorks==false}"></i>
				       			    </a>	       			    
				       				<a href="" ng-click="workspaceSrvc.toggleWorks()" class="toggle-text"><@orcid.msg 'workspace.Works'/> (<span ng-bind="worksSrvc.works.length"></span>)</a>
			       				</div>
			       			</div>	
			       			<div class="col-md-9 col-sm-9 col-xs-12" ng-show="workspaceSrvc.displayWorks">
			       				<a class="action-option manage-button sort-menu" ng-click="">
									<span class="glyphicon glyphicon-sort"></span>							
									<@orcid.msg ''/>Sort Items							
								</a>
								<ul class="sort-menu-options">
									<li><a href="">Title <span class=""></span></a></li>
									<li><a href="" class="checked">Data <span class="glyphicon glyphicon-ok pull-right"></span></a></li>
									<li><a href="">Type <span class=""></span></a></li>
									<li><a href="">Source <span class=""></span></a></li>
								</ul>
		                		<ul class="works-menu">
			        				<li>
			        					<a href="" class="action-option manage-button" ng-click="">
											<span class="glyphicon glyphicon-cog"></span>
											Manage View
										</a>	        				
			        				</li>
			        				<li>
				        				<a href="" class="action-option manage-button" ng-click="addWorkModal()">
											<span class="glyphicon glyphicon-plus"></span>
											<@orcid.msg 'manual_work_form_contents.add_work_manually'/>
										</a>
			        				</li>
			        				<li>
				        				<a class="action-option manage-button" ng-click="showWorkImportWizard()">
											<span class="glyphicon glyphicon-cloud-upload"></span>							
											<@orcid.msg 'workspace.link_works'/>
										</a>	        				
			        				</li>
								</ul>
							
							</div>
						</div>					
					</div>
					
      	            <div ng-show="workspaceSrvc.displayWorks" class="workspace-accordion-content">
	            		<#include "includes/work/add_work_modal_inc.ftl"/>
						<#include "includes/work/del_work_modal_inc.ftl"/>
						<#include "includes/work/body_work_inc.ftl"/>
	            	</div>
	            	
            	</div>
            	
            	<#--
        		<div id="workspace-fundings" class="workspace-accordion-item">
        			<div class="workspace-accordion-header"><a href="#"><@orcid.msg 'workspace.Grants'/></a></div>
            	</div>
            	
        		<div id="workspace-patents" class="workspace-accordion-item">
        			<div class="workspace-accordion-header"><a href="#"><@orcid.msg 'workspace.Patents'/></a></div>
            	</div>
            	-->
            	
            </div>
        </div>
    </div>    
</div>
</#escape>

<script type="text/ng-template" id="verify-email-modal">	
	<div class="lightbox-container">
		<div class="row">
			<div class="col-md-12 col-xs-12 col-sm-12">
				<h4><@orcid.msg 'workspace.your_primary_email'/></h4>
				<@orcid.msg 'workspace.ensure_future_access'/>
				<br />
				<br />						
				<span class="btn btn-primary" id="modal-close" ng-click="verifyEmail()"><@orcid.msg 'workspace.send_verification'/></span>
				<span class="btn" id="modal-close" ng-click="closeColorBox()"><@orcid.msg 'freemarker.btncancel'/></span>								
			</div>
		</div>		
	</div>		


</script>

<script type="text/ng-template" id="verify-email-modal-sent">
	<div class="lightbox-container">
		<div class="row">
			<div class="col-md-12 col-sm-12 col-xs-12">
				<h4><@orcid.msg 'workspace.sent'/></h4>
				<@orcid.msg 'workspace.check_your_email'/><br />
				<br />
				<span class="btn" ng-click="closeColorBox()"><@orcid.msg 'freemarker.btnclose'/></span>
			</div>
		</div>
	</div>
</script>

<script type="text/ng-template" id="claimed-record-thanks">
	<div class="lightbox-container">
		<div class="row">
			<div class="col-md-12 col-sm-12 col-xs-12">
				<strong><@spring.message "orcid.frontend.web.record_claimed"/></strong><br />
				<br />
				<button class="btn" ng-click="close()"><@spring.message "freemarker.btnclose"/></button>
			</div>
		</div>
	</div>
</script>
	
<script type="text/ng-template" id="claimed-record-thanks-source-grand-read">
	<div class="lightbox-container">
		<div class="row">
			<div class="col-md-12 col-sm-12 col-xs-12">
				<strong><@spring.message "orcid.frontend.web.record_claimed"/></strong><br />
				<br />
				<strong ng-bind="sourceGrantReadWizard.displayName"></strong> <@spring.message "orcid.frontend.web.record_claimed.would_like"/><br />
				<br />
				<button class="btn btn-primary" ng-click="yes()"><@spring.message "orcid.frontend.web.record_claimed.yes_go_to" /></button>
				<button class="btn" ng-click="close()"><@spring.message "orcid.frontend.web.record_claimed.no_thanks" /></button>
			</div>
		</div>
	</div>
</script>

<script type="text/ng-template" id="delete-external-id-modal">
	<div class="lightbox-container">
		<div class="row">
			<div class="col-md-12 col-sm-12 col-xs-12">
				<h3><@orcid.msg 'manage.deleteExternalIdentifier.pleaseConfirm'/> {{removeExternalModalText}} </h3>
				<button class="btn btn-danger" ng-click="removeExternalIdentifier()"><@orcid.msg 'manage.deleteExternalIdentifier.delete'/></button> 
				<a ng-click="closeModal()"><@orcid.msg 'freemarker.btncancel'/></a>
			<div>
		<div>
	<div>	
</script>

<script type="text/ng-template" id="import-wizard-modal">
    <#if ((workImportWizards)??)>		
    	<div id="third-parties">
			<div class="ie7fix-inner">
			<div class="row">	
				<div class="col-md-12 col-sm-12 col-xs-12">					
					<a class="btn pull-right close-button" ng-click="closeModal()">X</a>
	           		<h1 class="lightbox-title" style="text-transform: uppercase;"><@orcid.msg 'workspace.link_works'/></h1>
				</div>
			</div>
			<div class="row">
				<div class="col-md-12 col-sm-12 col-xs-12">
	    	    	<div class="justify">
						<p><@orcid.msg 'workspace.LinkResearchActivitiess.description'/></p>
					</div>            	    	           	
    		    	<#list workImportWizards?sort_by("displayName") as thirdPartyDetails>
	        	       	<#assign redirect = (thirdPartyDetails.redirectUris.redirectUri[0].value) >
            	   		<#assign predefScopes = (thirdPartyDetails.redirectUris.redirectUri[0].scopeAsSingleString) >
                   		<strong><a ng-click="openImportWizardUrl('<@spring.url '/oauth/authorize?client_id=${thirdPartyDetails.clientId}&response_type=code&scope=${predefScopes}&redirect_uri=${redirect}'/>')">${thirdPartyDetails.displayName}</a></strong><br />
                 		<div class="justify">
							<p>
								${(thirdPartyDetails.shortDescription)!}
							</p>
						</div>
                   		<#if (thirdPartyDetails_has_next)>
	                      	<hr/>
						</#if>
                		</#list>
				</div>
			</div>                 
            <div class="row footer">
				<div class="col-md-12 col-sm-12 col-xs-12">
					<p>
				   		<strong><@orcid.msg 'workspace.LinkResearchActivitiess.footer.title'/></strong>	    
	        			<@orcid.msg 'workspace.LinkResearchActivitiess.footer.description1'/> <a href="<@orcid.msg 'workspace.LinkResearchActivitiess.footer.description.url'/>"><@orcid.msg 'workspace.LinkResearchActivitiess.footer.description.link'/></a> <@orcid.msg 'workspace.LinkResearchActivitiess.footer.description2'/>
			    	</p>
				</div>
	        </div>
		</div>
		</div>
	</#if>
</script>

<script type="text/ng-template" id="import-funding-modal">
    <#if ((fundingImportWizards)??)>		
    	<div id="third-parties">
			<div class="ie7fix-inner">
			<div class="row">	
				<div class="col-md-12 col-sm-12 col-xs-12">					
					<a class="btn pull-right close-button" ng-click="closeModal()">X</a>
	           		<h1 class="lightbox-title" style="text-transform: uppercase;"><@orcid.msg 'workspace.link_funding'/></h1>
				</div>
			</div>
			<div class="row">
				<div class="col-md-12 col-sm-12 col-xs-12">
	    	    	<div class="justify">
						<p><@orcid.msg 'workspace.LinkResearchActivitiess.description'/></p>
					</div>            	    	           	
    		    	<#list fundingImportWizards?sort_by("displayName") as thirdPartyDetails>
	        	       	<#assign redirect = (thirdPartyDetails.redirectUris.redirectUri[0].value) >
            	   		<#assign predefScopes = (thirdPartyDetails.redirectUris.redirectUri[0].scopeAsSingleString) >
                   		<strong><a ng-click="openImportWizardUrl('<@spring.url '/oauth/authorize?client_id=${thirdPartyDetails.clientId}&response_type=code&scope=${predefScopes}&redirect_uri=${redirect}'/>')">${thirdPartyDetails.displayName}</a></strong><br />
                 		<div class="justify">
							<p>
								${(thirdPartyDetails.shortDescription)!}
							</p>
						</div>
                   		<#if (thirdPartyDetails_has_next)>
	                      	<hr/>
						</#if>
                		</#list>
				</div>
			</div>                 
            <div class="row footer">
				<div class="col-md-12 col-sm-12 col-xs-12">
					<p>
				   		<strong><@orcid.msg 'workspace.LinkResearchActivitiess.footer.title'/></strong>	    
	        			<@orcid.msg 'workspace.LinkResearchActivitiess.footer.description1'/> <a href="<@orcid.msg 'workspace.LinkResearchActivitiess.footer.description.url'/>"><@orcid.msg 'workspace.LinkResearchActivitiess.footer.description.link'/></a> <@orcid.msg 'workspace.LinkResearchActivitiess.footer.description2'/>
			    	</p>
				</div>
	        </div>
		</div>
		</div>
	</#if>
</script>
	
</@protected>
