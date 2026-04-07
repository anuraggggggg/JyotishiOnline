// lib/views/live/gift_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/liveController.dart';
import '../../controllers/newliveController.dart';
import '../../model/fastApiModel/giftModel.dart';
import '../../theme/appTheme.dart';
import 'gift_animation_overlay.dart';

// ─── Entry point ─────────────────────────────────────────────────────────────

/// Call this to open the gift bottom-sheet.
/// [LiveController] must already be registered with Get.put / Get.find.
void showGiftSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (_) => const _GiftSheet(),
  );
}

// ─── Sheet ────────────────────────────────────────────────────────────────────

class _GiftSheet extends StatelessWidget {
  const _GiftSheet();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<NewLiveController>();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF12121F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        border: Border(top: BorderSide(color: Color(0x12FFFFFF))),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header row
          _SheetHeader(ctrl: ctrl),
          const SizedBox(height: 20),

          // Gift grid
          Obx(() {
            if (ctrl.isLoadingGifts.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF7C6FF7)),
                ),
              );
            }
            if (ctrl.gifts.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No gifts available',
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
              );
            }
            return _GiftGrid(ctrl: ctrl);
          }),

          const SizedBox(height: 16),

          // Qty + total row
          Obx(() {
            if (ctrl.gifts.isEmpty) return const SizedBox.shrink();
            return _QtyRow(ctrl: ctrl);
          }),

          const SizedBox(height: 20),

          // Send button
          _SendButton(context: context, ctrl: ctrl),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  final NewLiveController ctrl;
  const _SheetHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF7C6FF7).withOpacity(0.15),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFF7C6FF7).withOpacity(0.3)),
          ),
          child: const Center(
            child: Text('🎁', style: TextStyle(fontSize: 22)),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Send a Gift',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Obx(() => Text(
                'to ${ctrl.astrologerName.value}',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              )),
            ],
          ),
        ),
        // Wallet balance pill
        Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💰 ', style: TextStyle(fontSize: 12)),
              Text(
                '₹${ctrl.walletBalance.value.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Color(0xFF7C6FF7),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

// ─── Gift Grid ───────────────────────────────────────────────────────────────

class _GiftGrid extends StatelessWidget {
  final NewLiveController ctrl;
  const _GiftGrid({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final gifts = ctrl.gifts;
      final selectedIdx = ctrl.selectedGiftIdx.value;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.82,
        ),
        itemCount: gifts.length,
        itemBuilder: (_, i) {
          final gift = gifts[i];
          final isSelected = i == selectedIdx;

          return GestureDetector(
            onTap: () => ctrl.selectGift(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF7C6FF7).withOpacity(0.15)
                    : Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? const Color(0xFF7C6FF7) : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    gift.icon,
                    style: const TextStyle(fontSize: 26),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    gift.name,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${gift.price}',
                    style: const TextStyle(
                      color: Color(0xFF7C6FF7),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}

// ─── Qty Row ─────────────────────────────────────────────────────────────────

class _QtyRow extends StatelessWidget {
  final NewLiveController ctrl;
  const _QtyRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
      children: [
        const Text(
          'Quantity',
          style: TextStyle(color: Colors.white38, fontSize: 13),
        ),
        const SizedBox(width: 14),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              _QtyBtn(label: '−', onTap: ctrl.decrementQty),
              SizedBox(
                width: 32,
                child: Text(
                  '${ctrl.giftQty.value}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _QtyBtn(label: '+', onTap: ctrl.incrementQty),
            ],
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Total',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
            const SizedBox(height: 1),
            Text(
              '₹${ctrl.giftTotal}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    ));
  }
}

class _QtyBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QtyBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}

// ─── Send Button ─────────────────────────────────────────────────────────────

class _SendButton extends StatelessWidget {
  final BuildContext context;
  final NewLiveController ctrl;
  const _SendButton({required this.context, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sending = ctrl.isSendingGift.value;
      final gift = ctrl.selectedGift;
      final total = ctrl.giftTotal;

      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: sending
              ? null
              : () async {
            final success = await ctrl.sendGift();
            if (success && context.mounted) {
              Navigator.of(context).pop();
              // Trigger particle animation
              GiftAnimationOverlay.show(
                context,
                giftEmoji: gift?.icon ?? '🎁',
                qty: ctrl.giftQty.value,
              );
              // Show success snackbar
              Get.snackbar(
                '🎁 Gift Sent!',
                '${gift?.name ?? 'Gift'} sent to ${ctrl.astrologerName.value}! ₹$total deducted.',
                backgroundColor: const Color(0xFF1E7A4A),
                colorText: Colors.white,
                snackPosition: SnackPosition.TOP,
                duration: const Duration(seconds: 3),
                margin: const EdgeInsets.all(12),
                borderRadius: 14,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C6FF7),
            disabledBackgroundColor: const Color(0xFF7C6FF7).withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: sending
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                gift?.icon ?? '🎁',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Send Gift · ₹$total',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}