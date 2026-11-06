import { useEffect, useState } from 'react';
import { useBackend, useLocalState } from '../backend';
import { DmIcon, Icon } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { Window } from '../layouts';

type WorkshopResource = {
  id: string;
  name: string;
  amount: number;
  icon: string;
  icon_state: string;
  can_withdraw: BooleanLike;
};

type RecipeRequirement = {
  id: string;
  name: string;
  required: number;
  available: number;
  missing: number;
};

type WorkshopRecipe = {
  ref: string;
  name: string;
  category: string;
  desc: string;
  output_name: string;
  output_icon: string;
  output_state: string;
  output_amount: number;
  requirements: RecipeRequirement[];
  service_fee: number;
  craft_time: number;
  resources_sufficient: BooleanLike;
  can_craft: BooleanLike;
};

type TechnicianWorkshopData = {
  title: string;
  budget: number;
  mammon_icon: string;
  mammon_icon_state: string;
  can_withdraw_mammons: BooleanLike;
  is_crafting: BooleanLike;
  active_recipe_name: string;
  active_recipe_ref: string;
  craft_time_remaining: number;
  craft_total_time: number;
  craft_time_snapshot: number;
  technician_icon: string;
  technician_state: string;
  resources: WorkshopResource[];
  categories: string[];
  recipes: WorkshopRecipe[];
};

const formatTime = (seconds: number) => {
  const safeSeconds = Math.max(0, Math.floor(seconds));
  const minutes = Math.floor(safeSeconds / 60);
  const remainingSeconds = safeSeconds % 60;
  return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
};

const Sprite = (props: { icon?: string; iconState?: string; size?: number }) => {
  const { icon, iconState, size = 3 } = props;
  if (!icon || !iconState) {
    return <Icon name="wrench" size={size} />;
  }

  return (
    <DmIcon
      fallback={<Icon name="wrench" size={size} />}
      icon={icon}
      icon_state={iconState}
      height={size}
      width={size}
    />
  );
};

const ResourceHeader = (props: {
  resources: WorkshopResource[];
  budget: number;
  mammonIcon: string;
  mammonIconState: string;
  canWithdrawMammons: boolean;
  onWithdrawResource: (resourceId: string) => void;
  onWithdrawMammons: () => void;
}) => {
  const {
    resources,
    budget,
    mammonIcon,
    mammonIconState,
    canWithdrawMammons,
    onWithdrawResource,
    onWithdrawMammons,
  } = props;

  return (
    <div className="TechnicianWorkshop__resource-header">
      <div className="TechnicianWorkshop__resource-heading">Deposited resources</div>
      <div className="TechnicianWorkshop__resource-values">
        {resources.map((resource) => (
          <button
            type="button"
            className="TechnicianWorkshop__resource-value"
            key={resource.id}
            disabled={!resource.can_withdraw || resource.amount <= 0}
            title={`Withdraw all ${resource.amount} ${resource.name} onto the workbench`}
            onClick={() => onWithdrawResource(resource.id)}
          >
            <Sprite icon={resource.icon} iconState={resource.icon_state} size={2} />
            <span className="TechnicianWorkshop__resource-copy">
              <span className="TechnicianWorkshop__resource-name">{resource.name}:</span>
              <b>{resource.amount}</b>
            </span>
          </button>
        ))}
        <button
          type="button"
          className="TechnicianWorkshop__resource-value TechnicianWorkshop__resource-money"
          disabled={!canWithdrawMammons || budget <= 0}
          title={`Withdraw all ${budget} amnas as coin change`}
          onClick={onWithdrawMammons}
        >
          <Sprite icon={mammonIcon} iconState={mammonIconState} size={2} />
          <span className="TechnicianWorkshop__resource-copy">
            <span className="TechnicianWorkshop__resource-name">Amnas depot:</span>
            <b>{budget} a</b>
          </span>
        </button>
      </div>
      <div className="TechnicianWorkshop__deposit-hint">
        Insert materials or coins to deposit them. Click a stocked resource or the amnas depot to withdraw its full balance.
      </div>
    </div>
  );
};

const RecipeEntry = (props: {
  recipe: WorkshopRecipe;
  selected: boolean;
  onSelect: () => void;
}) => {
  const { recipe, selected, onSelect } = props;
  const affordable = !!recipe.can_craft;
  const missingResources = !recipe.resources_sufficient;

  return (
    <button
      type="button"
      className={`TechnicianWorkshop__recipe-entry ${selected ? 'is-selected' : ''}`}
      onClick={onSelect}
    >
      <span className="TechnicianWorkshop__recipe-entry-name">{recipe.name}</span>
      <span className={`TechnicianWorkshop__recipe-status ${missingResources ? 'is-missing' : affordable ? 'is-ready' : ''}`}>
        {missingResources ? 'Missing materials' : affordable ? 'Available' : 'Unavailable'}
      </span>
    </button>
  );
};

const RequirementRows = (props: { requirements: RecipeRequirement[] }) => {
  const { requirements } = props;
  if (!requirements.length) {
    return <div className="TechnicianWorkshop__empty-cost">No material requirements.</div>;
  }

  return (
    <div className="TechnicianWorkshop__requirements">
      {requirements.map((requirement) => {
        const missing = requirement.missing > 0;
        return (
          <div
            className={`TechnicianWorkshop__requirement ${missing ? 'is-missing' : ''}`}
            key={requirement.id}
          >
            <span>{requirement.name}</span>
            <b>{requirement.available} / {requirement.required}</b>
            {missing && <span className="TechnicianWorkshop__missing-count">-{requirement.missing}</span>}
          </div>
        );
      })}
    </div>
  );
};

export const TechnicianWorkshop = () => {
  const { act, data } = useBackend<TechnicianWorkshopData>();
  const categories = data.categories || [];
  const recipes = data.recipes || [];

  // Persist the last category for this interface in the client's TGUI state.
  const [storedCategory, setStoredCategory] = useLocalState<string>(
    'technician-workshop-category',
    categories[0] || '',
  );
  const [selectedRecipeRef, setSelectedRecipeRef] = useLocalState<string>(
    'technician-workshop-recipe',
    '',
  );

  const busy = !!data.is_crafting;
  const activeCategory = categories.includes(storedCategory)
    ? storedCategory
    : categories[0] || '';
  const visibleRecipes = recipes.filter((recipe) => recipe.category === activeCategory);
  const activeRecipe = busy
    ? recipes.find((recipe) => recipe.ref === data.active_recipe_ref)
    : undefined;
  const selectedRecipe = activeRecipe
    || visibleRecipes.find((recipe) => recipe.ref === selectedRecipeRef)
    || visibleRecipes[0];

  // Backend sends a fresh snapshot on every UI update. Decrement it locally so
  // the visible countdown advances even when no server-side event occurs.
  const [snapshotReceivedAt, setSnapshotReceivedAt] = useState(() => Date.now());
  const [clientNow, setClientNow] = useState(() => Date.now());

  useEffect(() => {
    const receivedAt = Date.now();
    setSnapshotReceivedAt(receivedAt);
    setClientNow(receivedAt);
  }, [data.craft_time_snapshot]);

  useEffect(() => {
    if (!busy) {
      return;
    }
    const interval = window.setInterval(() => setClientNow(Date.now()), 250);
    return () => window.clearInterval(interval);
  }, [busy]);

  const localElapsedSeconds = Math.floor(Math.max(0, clientNow - snapshotReceivedAt) / 1000);
  const remaining = Math.max(0, (data.craft_time_remaining || 0) - localElapsedSeconds);
  const total = Math.max(1, data.craft_total_time || 1);
  const progress = busy ? Math.min(1, Math.max(0, 1 - remaining / total)) : 0;

  const enoughMaterials = !!selectedRecipe?.resources_sufficient;
  const enoughMoney = !!selectedRecipe && data.budget >= selectedRecipe.service_fee;
  const canCraft = !!selectedRecipe && !!selectedRecipe.can_craft && !busy;

  return (
    <Window>
      <Window.Content scrollable={false}>
        <div className="TechnicianWorkshop">
          <ResourceHeader
            resources={data.resources || []}
            budget={data.budget || 0}
            mammonIcon={data.mammon_icon}
            mammonIconState={data.mammon_icon_state}
            canWithdrawMammons={!!data.can_withdraw_mammons}
            onWithdrawResource={(resourceId) => act('withdraw_resource', { resource_id: resourceId })}
            onWithdrawMammons={() => act('withdraw_mammons')}
          />

          <div className="TechnicianWorkshop__main">
            <section className="TechnicianWorkshop__recipe-pane">
              <div className="TechnicianWorkshop__pane-heading">
                Recipe catalogue
                <span>{visibleRecipes.length} recipes</span>
              </div>
              <div className="TechnicianWorkshop__recipe-list">
                {visibleRecipes.length ? visibleRecipes.map((recipe) => (
                  <RecipeEntry
                    key={recipe.ref}
                    recipe={recipe}
                    selected={selectedRecipe?.ref === recipe.ref}
                    onSelect={() => setSelectedRecipeRef(recipe.ref)}
                  />
                )) : (
                  <div className="TechnicianWorkshop__empty-list">
                    No recipes in this category.
                  </div>
                )}
              </div>
            </section>

            <section className="TechnicianWorkshop__detail-pane">
              <div className={`TechnicianWorkshop__technician ${busy ? 'is-busy' : 'is-idle'}`}>
                <div className="TechnicianWorkshop__time-label">
                  {busy ? 'Time remaining' : 'Time to craft'}
                  <b>{busy ? formatTime(remaining) : selectedRecipe ? formatTime(selectedRecipe.craft_time) : '—'}</b>
                </div>
                <div className="TechnicianWorkshop__portrait-stage">
                  <div className="TechnicianWorkshop__portrait-sprite">
                    <Sprite
                      icon={data.technician_icon}
                      iconState={data.technician_state}
                      size={6}
                    />
                  </div>
                  {busy && (
                    <div className="TechnicianWorkshop__busy-label">
                      Working on {data.active_recipe_name || 'an order'}
                    </div>
                  )}
                </div>
                {busy && (
                  <div className="TechnicianWorkshop__progress-track">
                    <div
                      className="TechnicianWorkshop__progress-fill"
                      style={{ width: `${progress * 100}%` }}
                    />
                  </div>
                )}
              </div>

              <div className="TechnicianWorkshop__selected-recipe">
                {selectedRecipe ? (
                  <>
                    <div className="TechnicianWorkshop__selected-title">Selected recipe</div>
                    <div className="TechnicianWorkshop__output-row">
                      <Sprite
                        icon={selectedRecipe.output_icon}
                        iconState={selectedRecipe.output_state}
                        size={4}
                      />
                      <div className="TechnicianWorkshop__output-copy">
                        <div className="TechnicianWorkshop__output-name">
                          {selectedRecipe.output_name || selectedRecipe.name}
                          {selectedRecipe.output_amount > 1 && ` ×${selectedRecipe.output_amount}`}
                        </div>
                        <div className="TechnicianWorkshop__output-description">
                          {selectedRecipe.desc || 'No description available.'}
                        </div>
                      </div>
                    </div>
                  </>
                ) : (
                  <div className="TechnicianWorkshop__no-selection">Select a recipe.</div>
                )}
              </div>

              <div className="TechnicianWorkshop__cost-row">
                <div className="TechnicianWorkshop__material-cost">
                  <div className="TechnicianWorkshop__cost-heading">Material requirements</div>
                  {selectedRecipe ? (
                    <RequirementRows requirements={selectedRecipe.requirements || []} />
                  ) : (
                    <div className="TechnicianWorkshop__empty-cost">No recipe selected.</div>
                  )}
                </div>
                <div className="TechnicianWorkshop__fee-cost">
                  <div className="TechnicianWorkshop__cost-heading">Service fee</div>
                  <div className={`TechnicianWorkshop__fee-value ${!enoughMoney ? 'is-missing' : ''}`}>
                    {selectedRecipe ? `${selectedRecipe.service_fee} a` : '—'}
                  </div>
                  <div className="TechnicianWorkshop__depot-value">
                    You have: {data.budget || 0} a
                  </div>
                  {!enoughMoney && selectedRecipe && (
                    <div className="TechnicianWorkshop__missing-count">Insufficient amnas</div>
                  )}
                </div>
              </div>
            </section>
          </div>

          <div className="TechnicianWorkshop__footer">
            <div className="TechnicianWorkshop__categories">
              {categories.map((category) => (
                <button
                  type="button"
                  key={category}
                  className={`TechnicianWorkshop__category ${activeCategory === category ? 'is-active' : ''}`}
                  onClick={() => {
                    setStoredCategory(category);
                    setSelectedRecipeRef('');
                  }}
                >
                  {category}
                </button>
              ))}
            </div>
            <button
              type="button"
              className="TechnicianWorkshop__craft-button"
              disabled={!canCraft}
              onClick={() => selectedRecipe && act('start_craft', { recipe: selectedRecipe.ref })}
            >
              {busy ? 'Technician busy' : 'Craft'}
            </button>
          </div>

          {selectedRecipe && !busy && (!enoughMaterials || !enoughMoney) && (
            <div className="TechnicianWorkshop__footer-warning">
              {!enoughMaterials && 'Missing resources are shown in red.'}
              {!enoughMaterials && !enoughMoney && ' · '}
              {!enoughMoney && 'The workstation needs more amnas.'}
            </div>
          )}
          {busy && (
            <div className="TechnicianWorkshop__footer-warning">
              The technician is working. Deposits are still accepted, but another craft cannot start.
            </div>
          )}
        </div>
      </Window.Content>
    </Window>
  );
};
