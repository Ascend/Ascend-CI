jobs:
  check:
    runs-on: ubuntu-latest
    outputs:
      latest_tag: ${{ steps.get_tag.outputs.latest_tag }}
    steps:
      - id: get_tag
        run: |
          latest=$(python3 - <<'EOF'
import urllib.request, json
url = "https://pypi.org/pypi/onnxruntime-cann/json"
with urllib.request.urlopen(url) as resp:
    data = json.load(resp)
print(data["info"]["version"])
EOF
)
          echo "latest_tag=$latest" >> $GITHUB_OUTPUT

  build:
    needs: check
    name: Build for ${{ matrix.build_name }}
    runs-on: ${{ matrix.runner }}
    container:
      image: ${{ matrix.image }}
      env:
        PYPI_TOKEN: ${{ secrets.PYPI_TOKEN }}
      volumes:
        - ${{ github.workspace }}/Ascend-CI:/root/Ascend-CI
        - /home/last_tag.txt:/root/last_tag.txt:ro   # 只读挂载，防止写入
    strategy:
      matrix:
        include:
          - arch: x86_64
            runner: ONNXRuntime
            image: bachelor233/manylinux2_28-py310-cann8_1_x86_64
            build_name: x86_64-py310-cann8.1
          - arch: aarch
            runner: pypi-aarch
            image: bachelor233/manylinux2_28-py310-cann8_1_aarch
            build_name: aarch64-py310-cann8.1
          - arch: x86_64
            runner: ONNXRuntime
            image: bachelor233/manylinux2_28-py311-cann8.2.rc1-x86_64
            build_name: x86_64-py311-cann8.2rc1
          - arch: aarch
            runner: pypi-aarch
            image: bachelor233/manylinux2_28-py311-cann8.2.rc1-aarch64
            build_name: aarch64-py311-cann8.2rc1
    steps:
      - name: Clone ASCEND-CI project
        uses: actions/checkout@v4
        with:
          repository: Ascend/Ascend-CI
          path: Ascend-CI

      - name: Build and upload pypi
        working-directory: /root/Ascend-CI
        run: |
          chmod +x ./script/pypiPkg.sh
          ./script/pypiPkg.sh ${{ needs.check.outputs.latest_tag }}

  update:
    needs: [build]
    runs-on: ubuntu-latest
    steps:
      - name: Update last_tag
        run: |
          echo "${{ needs.check.outputs.latest_tag }}" > /home/last_tag.txt
