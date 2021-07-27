pragma solidity >=0.4.24 <0.6.11;

import "./Table.sol";

contract Itp {
    // event
    event SetEvent(int256 ret, string indexed hash_key, string indexed itp_data);

    constructor() public {
        createTable();
    }

    function createTable() private {
        TableFactory tf = TableFactory(0x1001);
        tf.createTable("t_itp", "hash_key", "itp_data");
    }

    function openTable() internal returns(Table) {
        TableFactory tf = TableFactory(0x1001);
        Table table = tf.openTable("t_itp");
        return table;
    }

    function get(string memory hash_key) public view returns(int256, string memory) {
        // 打开表
        TableFactory tf = TableFactory(0x1001);
        Table table = tf.openTable("t_itp");
        // 查询
        Entries entries = table.select(hash_key, table.newCondition());
        if (0 == uint256(entries.size())) {
            return (-1, "0");
        } else {
            Entry entry = entries.get(0);
            return (0, entry.getString("itp_data"));
        }
    }

    function set(string memory hash_key, string memory itp_data) public returns(int256){
        int256 ret_code = 0;
        int256 ret= 0;
        // 查询hashKey是否存在
        string memory temp_value;
        (ret, temp_value) = get(hash_key);
        if(ret != 0) {
            Table table = openTable();

            Entry entry = table.newEntry();
            entry.set("hash_key", hash_key);
            entry.set("itp_data", itp_data);
            // 插入
            int count = table.insert(hash_key, entry);
            if (count == 1) {
                // 成功
                ret_code = 0;
            } else {
                // 失败? 无权限或者其他错误
                ret_code = -2;
            }
        } else {
            // hashKey已存在
            ret_code = -1;
        }

        emit SetEvent(ret_code, hash_key, itp_data);

        return ret_code;
    }

}
