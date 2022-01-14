# bensh

### Simple <ins>ben</ins>chmarking using <ins>sh</ins>ell

> This is a preview, I'll add others kinds of benchmark soon

## Usage
> Test using the most popular DNS servers (see [ipv4.csv](ipv4.csv))
```shell
./bench
./bench youtube.com
```    

## TO-DO
- [ ] Add CPU, disk and connection benchmarking
- [ ] Added IPv6 DNS benchmarking
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
- [ ] Test DNS ordered by random
- [ ] Add bensh to [xpm](https://github.com/insign/xpm)

## License
[GNU Affero General Public License v3.0](LICENSE.md)

## Contribute
> For now, you can just make a PR.

Inspired by [delfer](https://github.com/delfer)'s [gist](https://gist.github.com/delfer/34f0d85d1f4474e6d9fd4c47f749bcb8)
