const { network } = require("hardhat");
const {
    developmentChains,
    INTIAL_SUPPLY,
} = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const ourToken = await deploy("OurToken", {
        from: deployer,
        args: [INTIAL_SUPPLY],
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    });
    log(`ourToken deployed at ${ourToken.address}`);

    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        await verify(ourToken.target, [INTIAL_SUPPLY]);
    }
};

module.exports.tags = ["all", "token"];
