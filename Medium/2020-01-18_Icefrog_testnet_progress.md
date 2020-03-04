Icefrog Testnet Progress
===

Darwinia icefrog testnet starts from 2020-01-02 03:29:36.
After about 2 weeks running, we are collecting the problems and information from the nodes participating in this test.

- The nodes stop producing blocks and running into unknown issues.
- The CPU usage of the nodes is very high, even overwhelming, so the nodes sometimes stop accidentally.
- There may be problems in synchronization processes, so the blocks are synced slowly.
- There are network issues for some nodes to connect to the boot nodes.
- The nodes serving wallet are overloaded, so the transactions broadcasting is slow.
  Such that some users manually apply the transactions twice, and run into duplicate transactions' error.
- The root operation of the wallet may fail with unintended white screens.

To summarize these issues, 
the penalty mechanism is working well, the nodes losing the ability to produce blocks will stop validate and slash 5%.
The current workaround method for slow synchronization is to clean up the data and synchronization again.
We are working hard to find the root issues and fix it, all issues are list and track on our github.
https://github.com/darwinia-network/darwinia/issues/205
In order to find out more deep issues in Darwinia network, we will do more tests on following situations.

- Runtime upgrading
- Network splitting

If you are interested in Darwinia network, or want to participate in our testnet.  Please learn more from our website and github.
- https://darwinia.network
- https://github.com/darwinia-network/darwinia
