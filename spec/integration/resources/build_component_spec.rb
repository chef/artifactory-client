require 'spec_helper'

module Artifactory
  describe Resource::BuildComponent, :integration do
    let(:build_component) { described_class.find('wicket') }

    describe '.all' do
      it 'returns an array of build component objects' do
        results = described_class.all
        expect(results).to be_a(Array)
        expect(results.first).to be_a(described_class)
      end
    end

    describe '.find' do
      it 'finds a build component by name' do
        expect(build_component).to be_a(described_class)
        expect(build_component.name).to eq('wicket')
        expect(build_component.last_started).to eq(Time.parse('2015-06-19T20:13:20.222Z'))
      end
    end

    describe '#delete' do
      let(:build_numbers) { %w( 51 52 )}
      let(:delete_all) { false }

      it 'deletes the specified builds from the component' do

        expect(build_component.delete(
          build_numbers: build_numbers,
          delete_all: delete_all
        )).to be_truthy
      end

      context 'no build numbers provided' do
        let(:build_numbers) { nil }

        it 'deletes no builds' do

          expect(build_component.delete(
            delete_all: delete_all
          )).to be_falsey
        end

        context 'the delete_all flag is true' do
          let(:delete_all) { true }

          it 'deletes the component and all builds' do
            expect(build_component.delete(
              delete_all: delete_all
            )).to be_truthy
          end
        end
      end
    end

    describe '#rename' do
      it 'renames the build component on the server' do

        expect(build_component.rename('fricket')).to be_truthy
      end
    end
  end
end
