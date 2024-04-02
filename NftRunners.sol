//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract NftRunners is ERC721, ERC721URIStorage {
    using Counters for Counters.Counter;
    using Strings for uint256;

    //NFT
    Counters.Counter public tokenIdCounter;
    string[] characters = [
        "https://ipfs.io/ipfs/QmTgqnhFBMkfT9s8PHKcdXBn1f5bG3Q5hmBaR4U6hoTvb1?filename=Chainlink_Elf.png",
        "https://ipfs.io/ipfs/QmZGQA92ri1jfzSu61JRaNQXYg1bLuM7p8YT83DzFA2KLH?filename=Chainlink_Knight.png",
        "https://ipfs.io/ipfs/QmW1toapYs7M29rzLXTENn3pbvwe8ioikX1PwzACzjfdHP?filename=Chainlink_Orc.png",
        "https://ipfs.io/ipfs/QmPMwQtFpEdKrUjpQJfoTeZS1aVSeuJT6Mof7uV29AcUpF?filename=Chainlink_Witch.png"
    ];

    struct Runner {
        string image;
        uint256 distance;
    }
    Runner[] public runners;

    constructor() ERC721("RunnerNFT", "RUN") {
        safeMint(msg.sender,0);
    }

    function safeMint(address to, uint256 charId) public {
        uint8 aux = uint8 (charId);
        require( (aux >= 0) && (aux <= 3), "invalid charId");
        string memory yourCharacterImage = characters[charId];

        runners.push(Runner(yourCharacterImage,0));

        uint256 tokenId = tokenIdCounter.current();
        string memory uri = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "RunnerNFT",',
                        '"description": "This is your character",',
                        '"image": "', runners[tokenId].image, '",'
                        '"attributes": [',
                        '{',
                            '"trait_type": "distance",',
                            '"value": ', runners[tokenId].distance.toString(),
                            '}]'
                        '}'
                    )
                )
            )
        );
        // Create token URI
        string memory finalTokenURI = string(
            abi.encodePacked("data:application/json;base64,", uri)
        );
        tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, finalTokenURI);
    }

    function run(uint256 tokenId, uint256 distance) public {
        runners[tokenId].distance += distance;

        string memory uri = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "RunnerNFT",',
                        '"description": "This is your character",',
                        '"image": "', runners[tokenId].image, '",'
                        '"attributes": [',
                        '{',
                            '"trait_type": "distance",',
                            '"value": ', runners[tokenId].distance.toString(),
                            '}]'
                        '}'
                    )
                )
            )
        );
        // Create token URI
        string memory finalTokenURI = string(
            abi.encodePacked("data:application/json;base64,", uri)
        );
        _setTokenURI(tokenId, finalTokenURI);
    }

    
    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}