const getSnakeCase = require("./getSnakeCase");

module.exports = getSingleCommand = ({ name, displayName, assetType }) => {
  return `google_compute_${getSnakeCase(assetType)}.${displayName} ${name}`;
};
