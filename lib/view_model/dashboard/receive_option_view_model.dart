import 'package:cake_wallet/bitcoin/bitcoin.dart';
import 'package:cake_wallet/zcash/zcash.dart';
import 'package:cw_core/receive_page_option.dart';
import 'package:cw_core/wallet_base.dart';
import 'package:cw_core/wallet_type.dart';
import 'package:mobx/mobx.dart';

part 'receive_option_view_model.g.dart';

class ReceiveOptionViewModel = ReceiveOptionViewModelBase with _$ReceiveOptionViewModel;

abstract class ReceiveOptionViewModelBase with Store {
  ReceiveOptionViewModelBase(this._wallet, this.initialPageOption)
      : selectedReceiveOption = initialPageOption ??
            ([WalletType.bitcoin, WalletType.litecoin].contains(_wallet.type)
                ? bitcoin!.getSelectedAddressType(_wallet)
                : (_wallet.type == WalletType.decred && _wallet.isTestnet)
                    ? ReceivePageOption.testnet
                    : _wallet.type == WalletType.zcash
                        ? zcash!.getSelectedAddressType(_wallet)
                        : ReceivePageOption.mainnet),
        _options = [] {
    final walletType = _wallet.type;
    switch (walletType) {
      case WalletType.bitcoin:
        _options = [
          ...bitcoin!.getBitcoinReceivePageOptions(_wallet),
          ...ReceivePageOptions.where((element) => element != ReceivePageOption.mainnet)
        ];
        break;
      case WalletType.litecoin:
        _options = [
          ...bitcoin!.getLitecoinReceivePageOptions(_wallet),
          ...ReceivePageOptions.where((element) => element != ReceivePageOption.mainnet)
        ];
        break;
      case WalletType.haven:
        _options = [ReceivePageOption.mainnet];
        break;
      case WalletType.decred:
        if (_wallet.isTestnet) {
          _options = [
            ReceivePageOption.testnet,
            ...ReceivePageOptions.where(
                (element) => element != ReceivePageOption.mainnet)
          ];
        } else {
          _options = ReceivePageOptions;
        }
        break;
      default:
        _options = ReceivePageOptions;
    }
  }

  final WalletBase _wallet;

  final ReceivePageOption? initialPageOption;

  @observable
  ReceivePageOption selectedReceiveOption;

  List<ReceivePageOption> get options => _wallet.walletAddresses.receivePageOptions;

  @action
  void selectReceiveOption(ReceivePageOption option) => selectedReceiveOption = option;
}
