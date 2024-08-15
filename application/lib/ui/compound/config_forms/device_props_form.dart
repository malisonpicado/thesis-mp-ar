import 'package:flutter/material.dart';
import 'package:tesis_app/models/fish.dart';
import 'package:tesis_app/ui/icons/app_icons.dart';

class DevicePropsForm extends StatefulWidget {
  final void Function(
    String samplingTime,
    String batteryMin,
    String phMin,
    String phMax,
    String tempMin,
    String tempMax,
    String tdsMin,
    String tdsMax,
    String ecMin,
    String ecMax,
    String tuMin,
    String tuMax,
  ) onContinue;
  final void Function() onBackward;
  final String defaultSamplingTime;
  final String defaultBatteryMin;
  final String defaultPhMin;
  final String defaultPhMax;
  final String defaultTempMin;
  final String defaultTempMax;
  final String defaulTtdsMin;
  final String defaulTtdsMax;
  final String defaultEcMin;
  final String defaultEcMax;
  final String defaultTuMin;
  final String defaultTuMax;
  final String? samplingTimeError;

  const DevicePropsForm(
      {super.key,
      required this.onContinue,
      required this.onBackward,
      required this.defaultSamplingTime,
      required this.defaultBatteryMin,
      required this.defaultPhMin,
      required this.defaultPhMax,
      required this.defaultTempMin,
      required this.defaultTempMax,
      required this.defaulTtdsMin,
      required this.defaulTtdsMax,
      required this.defaultEcMin,
      required this.defaultEcMax,
      required this.defaultTuMin,
      required this.defaultTuMax,
      this.samplingTimeError});

  @override
  State<DevicePropsForm> createState() {
    return _DevicePropsForm();
  }
}

class _DevicePropsForm extends State<DevicePropsForm> {
  late TextEditingController _samplingTimeController;
  late TextEditingController _batteryMinController;
  late TextEditingController _phMinController;
  late TextEditingController _phMaxController;
  late TextEditingController _tempMinController;
  late TextEditingController _tempMaxController;
  late TextEditingController _tdsMinController;
  late TextEditingController _tdsMaxController;
  late TextEditingController _ecMinController;
  late TextEditingController _ecMaxController;
  late TextEditingController _tuMinController;
  late TextEditingController _tuMaxController;
  bool _isMojarraSelected = false;
  bool _isTilapiaSelected = false;
  bool _isGuapoteSelected = false;

  @override
  void initState() {
    _samplingTimeController =
        TextEditingController(text: widget.defaultSamplingTime);
    _batteryMinController =
        TextEditingController(text: widget.defaultBatteryMin);

    _phMinController = TextEditingController(text: widget.defaultPhMin);
    _phMaxController = TextEditingController(text: widget.defaultPhMax);
    _tempMinController = TextEditingController(text: widget.defaultTempMin);
    _tempMaxController = TextEditingController(text: widget.defaultTempMax);
    _tdsMinController = TextEditingController(text: widget.defaulTtdsMin);
    _tdsMaxController = TextEditingController(text: widget.defaulTtdsMax);
    _ecMinController = TextEditingController(text: widget.defaultEcMin);
    _ecMaxController = TextEditingController(text: widget.defaultEcMax);
    _tuMinController = TextEditingController(text: widget.defaultTuMin);
    _tuMaxController = TextEditingController(text: widget.defaultTuMax);

    super.initState();
  }

  void _setRecommendedValues(Fish fishType) {
    setState(() {
      _phMinController.text = fishType.ph.min.toString();
      _phMaxController.text = fishType.ph.max.toString();
      _tempMinController.text = fishType.temperature.min.toString();
      _tempMaxController.text = fishType.temperature.max.toString();
      _tdsMinController.text = fishType.tds.min.toString();
      _tdsMaxController.text = fishType.tds.max.toString();
      _ecMinController.text = fishType.ec.min.toString();
      _ecMaxController.text = fishType.ec.max.toString();
      _tuMinController.text = fishType.tu.min.toString();
      _tuMaxController.text = fishType.tu.max.toString();
    });
  }

  void _setSelectedFish(Fish fishType, bool isSelected) {
    switch (fishType) {
      case Fish.mojarra:
        setState(() {
          _isMojarraSelected = isSelected;
          _isGuapoteSelected = false;
          _isTilapiaSelected = false;
        });
        if (isSelected) _setRecommendedValues(fishType);
        break;
      case Fish.guapote:
        setState(() {
          _isMojarraSelected = false;
          _isGuapoteSelected = isSelected;
          _isTilapiaSelected = false;
        });
        if (isSelected) _setRecommendedValues(fishType);
      case Fish.tilapia:
        setState(() {
          _isMojarraSelected = false;
          _isGuapoteSelected = false;
          _isTilapiaSelected = isSelected;
        });
        if (isSelected) _setRecommendedValues(fishType);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Column(
      children: [
        Text(
          "Configuración de propiedades",
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium!
              .copyWith(color: theme.colorScheme.onSurface),
        ),
        const SizedBox(
          height: 32.0,
        ),
        TextField(
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: "Tiempo de muestreo (minutos)",
            errorText: widget.samplingTimeError,
            filled: false,
          ),
          controller: _samplingTimeController,
          keyboardType: TextInputType.number,
        ),
        // const SizedBox(
        //   height: 20.0,
        // ),
        // TextField(
        //   decoration: InputDecoration(
        //     border: const OutlineInputBorder(),
        //     labelText: "Nivel de batería mínimo:",
        //     errorText: widget.samplingTimeError,
        //     filled: false,
        //   ),
        //   controller: _batteryMinController,
        //   keyboardType: TextInputType.number,
        // ),
        const SizedBox(
          height: 24.0,
        ),
        Row(
          children: [
            Expanded(
                child: Text(
              "(Opcional) Selecciona uno de los siguientes peces:",
              softWrap: true,
              style: theme.textTheme.bodyLarge!
                  .copyWith(color: theme.colorScheme.onSurface),
            ))
          ],
        ),
        const SizedBox(
          height: 16.0,
        ),
        Row(
          children: [
            Wrap(
              spacing: 16.0,
              children: [
                ChoiceChip(
                  label: const Text("Mojarra"),
                  selected: _isMojarraSelected,
                  onSelected: (isSelected) =>
                      {_setSelectedFish(Fish.mojarra, isSelected)},
                ),
                ChoiceChip(
                  label: const Text("Tilapia"),
                  selected: _isTilapiaSelected,
                  onSelected: (isSelected) =>
                      {_setSelectedFish(Fish.tilapia, isSelected)},
                ),
                ChoiceChip(
                  label: const Text("Guapote"),
                  selected: _isGuapoteSelected,
                  onSelected: (isSelected) =>
                      {_setSelectedFish(Fish.guapote, isSelected)},
                ),
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 24.0,
        ),
        Row(
          children: [
            Expanded(
                child: Text(
              "Valores mínimos y máximos para cada propiedad físico-química:",
              softWrap: true,
              style: theme.textTheme.bodyLarge!
                  .copyWith(color: theme.colorScheme.onSurface),
            ))
          ],
        ),
        const SizedBox(
          height: 16.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ValueTextField(controller: _phMinController, label: "pH"),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: ValueTextField(
                  controller: _phMaxController, label: "pH", isMin: false),
            )
          ],
        ),
        const SizedBox(
          height: 24.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ValueTextField(
                  controller: _tempMinController, label: "Temperatura"),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: ValueTextField(
                  controller: _tempMaxController,
                  label: "Temperatura",
                  isMin: false),
            )
          ],
        ),
        const SizedBox(
          height: 24.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child:
                  ValueTextField(controller: _tdsMinController, label: "TDS"),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: ValueTextField(
                  controller: _tdsMaxController, label: "TDS", isMin: false),
            )
          ],
        ),
        const SizedBox(
          height: 24.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ValueTextField(
                  controller: _ecMinController, label: "Conductividad E."),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: ValueTextField(
                  controller: _ecMaxController,
                  label: "Conductividad E.",
                  isMin: false),
            )
          ],
        ),
        const SizedBox(
          height: 24.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ValueTextField(
                  controller: _tuMinController, label: "Turbidez"),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: ValueTextField(
                  controller: _tuMaxController,
                  label: "Turbidez",
                  isMin: false),
            )
          ],
        ),
        const SizedBox(
          height: 32.0,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          OutlinedButton.icon(
              onPressed: widget.onBackward,
              icon: const Icon(AppIcons.arrow_back),
              label: const Text("Anterior")),
          FilledButton.icon(
              onPressed: () => {
                    widget.onContinue(
                      _samplingTimeController.text,
                      _batteryMinController.text,
                      _phMinController.text,
                      _phMaxController.text,
                      _tempMinController.text,
                      _tempMaxController.text,
                      _tdsMinController.text,
                      _tdsMaxController.text,
                      _ecMinController.text,
                      _ecMaxController.text,
                      _tuMinController.text,
                      _tuMaxController.text,
                    )
                  },
              icon: const Icon(AppIcons.arrow_forward),
              label: const Text("Siguiente"))
        ])
      ],
    );
  }

  @override
  void dispose() {
    _samplingTimeController.dispose();
    _batteryMinController.dispose();
    _phMinController.dispose();
    _phMaxController.dispose();
    _tempMinController.dispose();
    _tempMaxController.dispose();
    _tdsMinController.dispose();
    _tdsMaxController.dispose();
    _ecMinController.dispose();
    _ecMaxController.dispose();
    _tuMinController.dispose();
    _tuMaxController.dispose();
    super.dispose();
  }
}

class ValueTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool? isMin;
  const ValueTextField(
      {super.key,
      required this.controller,
      required this.label,
      this.isMin = true});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        helperText: "Valor ${isMin! ? "mínimo" : "máximo"}",
        filled: false,
      ),
      keyboardType: TextInputType.number,
      controller: controller,
    );
  }
}
