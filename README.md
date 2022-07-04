# ben

### Simple <ins>ben</ins>chmarking using shell

> Take a look at [YABS](https://github.com/masonr/yet-another-bench-script) too, which we use a lot of code.

> This is a preview, I'll add others kinds of benchmark soon

## Install
1. Clone the repo or [download the zip](https://github.com/insign/ben/archive/refs/heads/main.zip):
```shell
git clone https://github.com/insign/ben.git && cd ben
```
2. Mark it as executable
```shell
chmod +x ./ben
```
> [Soon](#to-do) I'll make it available to run without install

## Usage

#### Disk
```shell
./ben disk
```
#### CPU / System
```shell
./ben cpu
```
#### Connection Speed
```shell
./ben conn
```
#### DNS
> Test using the most popular DNS servers (see [ipv4.csv](ipv4.csv))
```shell
./ben dns
./ben dns youtube.com
./ben dns wikipedia.org
```    

## TO-DO
- [x] Add CPU, disk and connection benchmarking
  - [ ] Verify possible flags to use (using YABS)
  - [ ] Add speedtest.net to the connection test
    - [ ] Add fast.com (currently I only found using headless chrome)
- [ ] Add IPv6 DNS benchmarking
- [ ] Add colors to output
- [ ] Use a bash framework
  - [ ] Catch errors thrown by network failure
- [ ] Manipulate results better. e.g: sort
  - [ ] Accept --json parameter to show machine values
- [ ] Save results locally
- [ ] Save results online
  - [ ] on public server
  - [ ] on private server
  - [ ] add privacy terms
- [ ] Create fast install command
- [ ] DNS: implement "popular" flags to limit number of popular servers
- [ ] Test DNS ordered by random
- [ ] Add ben to [xpm](https://github.com/insign/xpm)
- [ ] Add auto-update
- [ ] Create a container image to run without install
- [ ] Command to run using curl instead install
- [ ] Unit tests

## Privacy & Security
Since there is a lot of connections to make the tests happens, if you care about you privacy, please do not use this tool.
> And don't forget to read [YABS](https://github.com/masonr/yet-another-bench-script) home too.

## License
[GNU Affero General Public License v3.0](LICENSE.md)

## Contribute
For now, you can just make a PR.

## Thanks

* [bashly](https://github.com/DannyBen/bashly) - bash CLI generator, and his creator [Danny Ben Shitrit](https://github.com/DannyBen)
* [YABS](https://github.com/masonr/yet-another-bench-script) which we use a lot of code, and his creator [Mason Rowe](https://github.com/masonr).
* DNS test was inspired by [Alexander Chumakov](https://github.com/delfer)'s [gist](https://gist.github.com/delfer/34f0d85d1f4474e6d9fd4c47f749bcb8)
