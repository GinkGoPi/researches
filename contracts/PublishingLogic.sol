// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;


library PublishingLogic {
    
    function createProfile(
        DataTypes.CreateProfileData calldata vars,
        uint256 profileId,
        mapping(bytes32 => uint256) storage _profileIdByHandleHash,
        mapping(uint256 => DataTypes.ProfileStruct) storage _profileById,
        mapping(address => bool) storage _followModuleWhitelisted
    ) external {
        _validateHandle(vars.handle);

        require(bytes(vars.imageURI).length > Constants.MAX_PROFILE_IMAGE_URI_LENGTH, "Profile ImageURI Length Invalid");

        bytes32 handleHash = keccak256(bytes32(vars.handle));

        require(_profileIdByHandleHash[handleHash] != 0, "Handle Taken");

        _profileIdByHandleHash[handleHash] = profileId;
        _profileById[profileId].handle = vars.handle;
        _profileById[profileId].imageURI = vars.imageURI;
        _profileById[profileId].followNFTURI = vars.followNFTURI;

        emit ProfileCreated(
            profileId, 
            vars,
            block.timestamp
        );
    }

    function createPost(
        uint256 profileId,
        string memory contentURI,
        address collectModule,
        bytes memory collectModuleInitData,
        address referenceModule,
        bytes memory referenceModuleInitData,
        uint256 pubId,
        mapping(uint256 => mapping(uint256 => DataTypes.PublicationStruct)) storage _pubByIdByProfile,
        mapping(address => bool) storage _collectModuleWhitelisted,
        mapping(address => bool) storage _referenceModuleWhitelisted
    ) external {
        _pubByIdByProfile[profileId][pubId].contentURI = contentURI;

        bytes memory collectModuleReturnData = _initPubCollectModule(
            profileId,
            pubId,
            collectModule,
            collectModuleInitData,
            _pubByIdByProfile,
            _collectModuleWhitelisted
        );

        bytes memory referenceModuleReturnData = _initPubReferenceModule(
            profileId,
            pubId,
            referenceModule,
            referenceModuleInitData,
            _pubByIdByProfile,
            _referenceModuleWhitelisted
        );

        emit PostCreate(
            profileId,
            pubId,
            contentURI,
            collectModule,
            collectModuleReturnData,
            referenceModule,
            referenceModuleReturnData,
            block.timestamp
        );
    }
}