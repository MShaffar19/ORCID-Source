/**
 * =============================================================================
 *
 * ORCID (R) Open Source
 * http://orcid.org
 *
 * Copyright (c) 2012-2014 ORCID, Inc.
 * Licensed under an MIT-Style License (MIT)
 * http://orcid.org/open-source-license
 *
 * This copyright and license information (including a link to the full license)
 * shall be included in its entirety in all copies or substantial portion of
 * the software.
 *
 * =============================================================================
 */
package org.orcid.core.manager.impl;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.orcid.core.adapter.JpaJaxbResearcherUrlAdapter;
import org.orcid.core.exception.ApplicationException;
import org.orcid.core.exception.OrcidDuplicatedElementException;
import org.orcid.core.manager.OrcidSecurityManager;
import org.orcid.core.manager.ProfileEntityManager;
import org.orcid.core.manager.ResearcherUrlManager;
import org.orcid.core.manager.SourceManager;
import org.orcid.core.manager.validator.PersonValidator;
import org.orcid.core.security.visibility.OrcidVisibilityDefaults;
import org.orcid.jaxb.model.common.Visibility;
import org.orcid.jaxb.model.record_rc2.ResearcherUrl;
import org.orcid.jaxb.model.record_rc2.ResearcherUrls;
import org.orcid.persistence.dao.ProfileDao;
import org.orcid.persistence.dao.ResearcherUrlDao;
import org.orcid.persistence.jpa.entities.ProfileEntity;
import org.orcid.persistence.jpa.entities.ResearcherUrlEntity;
import org.orcid.persistence.jpa.entities.SourceEntity;
import org.orcid.pojo.ajaxForm.PojoUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.transaction.annotation.Transactional;

public class ResearcherUrlManagerImpl implements ResearcherUrlManager {

    private static final Logger LOGGER = LoggerFactory.getLogger(ResearcherUrlManagerImpl.class);

    @Resource
    private ResearcherUrlDao researcherUrlDao;

    @Resource
    private ProfileDao profileDao;

    @Resource
    private SourceManager sourceManager;

    @Resource
    private ProfileEntityManager profileEntityManager;

    @Resource
    private JpaJaxbResearcherUrlAdapter jpaJaxbResearcherUrlAdapter;
    
    @Resource
    private OrcidSecurityManager orcidSecurityManager;

    @Override
    public boolean deleteResearcherUrl(String orcid, Long id, boolean checkSource) {
        boolean result = true;        
        ResearcherUrlEntity toDelete = researcherUrlDao.getResearcherUrl(orcid, id);          
        if(checkSource) {
            SourceEntity existingSource = toDelete.getSource();
            orcidSecurityManager.checkSource(existingSource);
        }
        
        try {            
            researcherUrlDao.deleteResearcherUrl(orcid, id);
        } catch(Exception e) {
            LOGGER.error("Unable to delete researcherUrl with ID: " + id);
            result = false;
        }
        return result;
    }   

    /**
     * Update the researcher urls associated with a specific account
     * 
     * @param orcid
     * @param researcherUrls
     * */
    @Override
    @Transactional
    public ResearcherUrls updateResearcherUrls(String orcid, ResearcherUrls researcherUrls, Visibility defaultVisibility) {
        List<ResearcherUrlEntity> existingEntities = researcherUrlDao.getResearcherUrls(orcid);
        if(defaultVisibility == null) {
            defaultVisibility = Visibility.fromValue(OrcidVisibilityDefaults.RESEARCHER_URLS_DEFAULT.getVisibility().value());
        }
        
        //Delete the deleted ones
        for(ResearcherUrlEntity existingEntity : existingEntities) {
            boolean deleteMe = true;
            for(ResearcherUrl updatedOrNew : researcherUrls.getResearcherUrls()) {
                if(existingEntity.getId().equals(updatedOrNew.getPutCode())) {
                    deleteMe = false;
                    break;
                }
            }
            
            if(deleteMe) {
                try {
                    researcherUrlDao.deleteResearcherUrl(existingEntity.getProfile().getId(), existingEntity.getId());
                } catch (Exception e) {
                    throw new ApplicationException("Unable to delete researcher url " + existingEntity.getId(), e);
                }
            }
        }
        
        // Update or create new
        if(researcherUrls != null && researcherUrls.getResearcherUrls() != null) {
            for(ResearcherUrl updatedOrNew : researcherUrls.getResearcherUrls()) {
                if(updatedOrNew.getPutCode() != null) {
                    //Update the existing ones
                   for(ResearcherUrlEntity existingEntity : existingEntities) {
                       if(existingEntity.getId().equals(updatedOrNew.getPutCode())) {
                           existingEntity.setLastModified(new Date());
                           existingEntity.setVisibility((updatedOrNew.getVisibility() == null) ?  Visibility.fromValue(defaultVisibility.value()) : updatedOrNew.getVisibility());                           
                           existingEntity.setUrl(updatedOrNew.getUrl().getValue());
                           existingEntity.setUrlName(updatedOrNew.getUrlName());
                           researcherUrlDao.merge(existingEntity);
                       }
                   }
                } else {
                    //Add the new ones
                    ResearcherUrlEntity newResearcherUrl = jpaJaxbResearcherUrlAdapter.toResearcherUrlEntity(updatedOrNew);
                    SourceEntity sourceEntity = sourceManager.retrieveSourceEntity();
                    ProfileEntity profile = new ProfileEntity(orcid);
                    newResearcherUrl.setUser(profile);
                    newResearcherUrl.setDateCreated(new Date());
                    newResearcherUrl.setLastModified(new Date());
                    newResearcherUrl.setSource(sourceEntity);
                    newResearcherUrl.setVisibility(Visibility.fromValue(defaultVisibility.value()));
                    researcherUrlDao.persist(newResearcherUrl);                    
                }
            }
        }
        
        if(defaultVisibility != null) {
            profileDao.updateResearcherUrlsVisibility(orcid, org.orcid.jaxb.model.message.Visibility.fromValue(defaultVisibility.value()));
        }
        return researcherUrls;
    }

    /**
     * Return the list of public researcher urls associated to a specific profile
     * 
     * @param orcid
     * @return the list of public researcher urls associated with the orcid profile
     * */
    @Override
    public org.orcid.jaxb.model.record_rc2.ResearcherUrls getPublicResearcherUrlsV2(String orcid) {
        return getResearcherUrlsV2(orcid, Visibility.PUBLIC);
    }
    
    /**
     * Return the list of researcher urls associated to a specific profile
     * 
     * @param orcid
     * @return the list of researcher urls associated with the orcid profile
     * */
    @Override
    public org.orcid.jaxb.model.record_rc2.ResearcherUrls getResearcherUrlsV2(String orcid) {
        return getResearcherUrlsV2(orcid, null);
    }
    
    /**
     * Return the list of researcher urls associated to a specific profile
     * 
     * @param orcid
     * @return the list of researcher urls associated with the orcid profile
     * */
    private org.orcid.jaxb.model.record_rc2.ResearcherUrls getResearcherUrlsV2(String orcid, Visibility visibility) {
        List<ResearcherUrlEntity> researcherUrlEntities = null; 
        if(visibility == null) {
            researcherUrlEntities = researcherUrlDao.getResearcherUrls(orcid);
        } else {
            researcherUrlEntities = researcherUrlDao.getResearcherUrls(orcid, visibility);
        }       
        
        return jpaJaxbResearcherUrlAdapter.toResearcherUrlList(researcherUrlEntities);
    }

    @Override
    public org.orcid.jaxb.model.record_rc2.ResearcherUrl getResearcherUrlV2(String orcid, long id) {
        ResearcherUrlEntity researcherUrlEntity = researcherUrlDao.getResearcherUrl(orcid, id);        
        return jpaJaxbResearcherUrlAdapter.toResearcherUrl(researcherUrlEntity);
    }

    @Override
    @Transactional
    public org.orcid.jaxb.model.record_rc2.ResearcherUrl updateResearcherUrlV2(String orcid, org.orcid.jaxb.model.record_rc2.ResearcherUrl researcherUrl) {
        SourceEntity sourceEntity = sourceManager.retrieveSourceEntity();                
        // Validate the researcher url
        PersonValidator.validateResearcherUrl(researcherUrl, sourceEntity, false);        
        // Validate it is not duplicated
        List<ResearcherUrlEntity> existingResearcherUrls = researcherUrlDao.getResearcherUrls(orcid);
        
        for (ResearcherUrlEntity existing : existingResearcherUrls) {
            if (isDuplicated(existing, researcherUrl, sourceEntity)) {
                Map<String, String> params = new HashMap<String, String>();
                params.put("type", "researcher-url");
                params.put("value", researcherUrl.getUrlName());
                throw new OrcidDuplicatedElementException(params);
            }
        }
                
        ResearcherUrlEntity updatedResearcherUrlEntity = researcherUrlDao.getResearcherUrl(orcid, researcherUrl.getPutCode());        
        Visibility originalVisibility = Visibility.fromValue(updatedResearcherUrlEntity.getVisibility().value());        
        SourceEntity existingSource = updatedResearcherUrlEntity.getSource();
        orcidSecurityManager.checkSource(existingSource);
        jpaJaxbResearcherUrlAdapter.toResearcherUrlEntity(researcherUrl, updatedResearcherUrlEntity);        
        updatedResearcherUrlEntity.setLastModified(new Date());
        updatedResearcherUrlEntity.setVisibility(originalVisibility);
        updatedResearcherUrlEntity.setSource(existingSource);
        researcherUrlDao.merge(updatedResearcherUrlEntity);
        return jpaJaxbResearcherUrlAdapter.toResearcherUrl(updatedResearcherUrlEntity);
    }

    @Override
    public org.orcid.jaxb.model.record_rc2.ResearcherUrl createResearcherUrlV2(String orcid, org.orcid.jaxb.model.record_rc2.ResearcherUrl researcherUrl) {
        SourceEntity sourceEntity = sourceManager.retrieveSourceEntity();
        // Validate the researcher url
        PersonValidator.validateResearcherUrl(researcherUrl, sourceEntity, true);
        // Validate it is not duplicated
        List<ResearcherUrlEntity> existingResearcherUrls = researcherUrlDao.getResearcherUrls(orcid);
        for (ResearcherUrlEntity existing : existingResearcherUrls) {
            if (isDuplicated(existing, researcherUrl, sourceEntity)) {
                Map<String, String> params = new HashMap<String, String>();
                params.put("type", "researcher-url");
                params.put("value", researcherUrl.getUrlName());
                throw new OrcidDuplicatedElementException(params);
            }
        }
        
        ResearcherUrlEntity newEntity = jpaJaxbResearcherUrlAdapter.toResearcherUrlEntity(researcherUrl);
        ProfileEntity profile = new ProfileEntity(orcid);
        newEntity.setUser(profile);
        newEntity.setDateCreated(new Date());
        newEntity.setSource(sourceEntity);
        setIncomingPrivacy(newEntity, profile);
        researcherUrlDao.persist(newEntity);
        return jpaJaxbResearcherUrlAdapter.toResearcherUrl(newEntity);
    }

    private boolean isDuplicated(ResearcherUrlEntity existing, org.orcid.jaxb.model.record_rc2.ResearcherUrl newResearcherUrl, SourceEntity source) {
        if (!existing.getId().equals(newResearcherUrl.getPutCode())) {
            if (existing.getSource() != null) {
                // If they have the same source
                if (!PojoUtil.isEmpty(existing.getSource().getSourceId()) && existing.getSource().getSourceId().equals(source.getSourceId())) {
                    // If the url is the same
                    if (existing.getUrl() != null && existing.getUrl().equals(newResearcherUrl.getUrl().getValue())) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    private void setIncomingPrivacy(ResearcherUrlEntity entity, ProfileEntity profile) {
        org.orcid.jaxb.model.common.Visibility incomingWorkVisibility = entity.getVisibility();
        org.orcid.jaxb.model.common.Visibility defaultResearcherUrlsVisibility = profile.getResearcherUrlsVisibility() == null ? org.orcid.jaxb.model.common.Visibility.PRIVATE : org.orcid.jaxb.model.common.Visibility.fromValue(profile.getResearcherUrlsVisibility()
                .value());
        if (profile.getClaimed() != null && profile.getClaimed()) {
            if (defaultResearcherUrlsVisibility.isMoreRestrictiveThan(incomingWorkVisibility)) {
                entity.setVisibility(defaultResearcherUrlsVisibility);
            }
        } else if (incomingWorkVisibility == null) {
            entity.setVisibility(org.orcid.jaxb.model.common.Visibility.PRIVATE);
        }
    }        
}
